require "../_util/text_util"
require "./tools/r2_client"
require "./nvchap/ch_util"

# storing book names

class CV::Chinfo
  include Clear::Model

  self.table = "chinfos"
  primary_key type: :serial

  belongs_to viuser : Viuser?, foreign_key_type: Int32
  belongs_to chroot : Nvseed, foreign_key_type: Int32
  belongs_to mirror : Chinfo?, foreign_key_type: Int32
  has_one cttran : Cttran?, foreign_key_type: Int32

  getter trans : Cttran { @cttran ||= Cttran.new(self, nil) }

  column chidx : Int16
  column schid : String

  column title : String = ""
  column chvol : String = ""

  column parts : Array(String)?

  column w_count : Int32 = 0
  column p_count : Int32 = 0

  column changed_at : Time?

  timestamps

  scope :filter_chroot do |chroot_id|
    where("chroot_id = #{chroot_id}")
      .select("id, chidx, schid, title, chvol, changed_at, w_count, p_count, mirror_id")
      .with_viuser
  end

  def initialize(chroot : Nvseed, argv : Array(String))
    @persisted = false
    self.chroot = chroot

    self.chidx = argv[0].to_i16
    self.schid = argv[1]

    return if argv.size < 4
    self.title = argv[2]
    self.chvol = argv[3]

    return if argv.size < 7

    self.changed_at = argv[4].to_i64?.try { |x| Time.unix(x) }
    self.w_count = argv[5].to_i
    self.p_count = argv[6].to_i16
    self.viuser = Viuser.find({uname: argv[7]? || ""})

    return if argv.size < 10

    mirror_chroot = Nvseed.find!({sname: argv[8], snvid: argv[9]})
    mirror_chroot.seed_chaps_from_disk! unless mirror_chroot.seeded

    mirror_chidx = argv[10]?.try(&.to_i16) || self.chidx
    self.mirror = Chinfo.find({chroot_id: mirror_chroot.id, chidx: mirror_chidx})
  end

  def text(cpart : Int16 = 0, redo : Bool = false, viuser : Viuser? = nil) : String
    self.mirror.try(&.text(cpart, redo, viuser)) || begin
      if self.parts_column.defined? && (parts = self.parts_column.value)
        text = parts[cpart]?
      elsif cpart < self.p_count
        text = load_text_from_db(cpart) || load_text_from_disk(cpart)
      end

      return text if !redo && text
      load_text_from_remote(cpart, redo, viuser) || text || ""
    end
  end

  def load_text_from_db(cpart : Int16) : String?
    Clear::SQL.select("parts[#{cpart &+ 1}]").from("chinfos")
      .where("id = #{self.id}")
      .scalar(String?)
  end

  DIR = "var/chtexts"

  def load_text_from_disk(cpart : Int16) : String?
    pgidx = (self.chidx &- 1) // 128
    store = "#{DIR}/#{chroot.sname}/#{chroot.snvid}/#{pgidx}.zip"
    return unless File.exists?(store) || load_store_from_remote(store)

    Compress::Zip::File.open(store) do |zip|
      parts = [] of String

      self.p_count.times do |index|
        file_name = "#{self.schid}-#{index}.txt"
        return unless entry = zip[file_name]?
        parts << entry.open(&.gets_to_end)

        if !(time = self.changed_at) || time < entry.time
          self.changed_at = entry.time
        end
      end

      parts.tap { |x| self.parts = x; self.save! }[cpart]?
    end
  end

  def load_store_from_remote(store : String) : Bool
    if File.exists?(store.sub(".zip", ".tab"))
      return R2Client.download(store.sub(DIR, "texts"), store)
    end

    return false unless chroot.sname == "jx_la"
    `aws s3 cp "#{store.sub(/^var/, "s3://chivi-bak")}" "#{store}"`
    $?.success?
  end

  def load_text_from_remote(cpart : Int16, redo : Bool = false, viuser : Viuser? = nil) : String?
    return unless chroot.is_remote

    ttl = redo ? 1.minutes : 10.years
    remote = RemoteText.new(chroot.sname, chroot.snvid, schid, ttl: ttl)

    lines = remote.paras
    # TODO: check for empty title in parser
    lines.unshift(remote.title) unless remote.title.empty?

    self.changed_at = Time.utc
    self.w_count, parts = ChUtil.split_parts(lines)
    self.p_count = parts.size
    self.viuser = viuser
    self.parts = parts
    self.save!

    parts[cpart]?
  rescue err
    Log.error(exception: err) { [self.schid, self.chidx] }
  end
end
