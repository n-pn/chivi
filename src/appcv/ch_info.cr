require "../_util/text_util"
require "../tools/r2_client"
require "./nvchap/ch_util"

# storing book names

class CV::Chinfo
  include Clear::Model

  self.table = "chinfos"
  primary_key type: :serial

  belongs_to viuser : Viuser?, foreign_key_type: Int32
  belongs_to chroot : Chroot, foreign_key_type: Int32
  belongs_to mirror : Chinfo?, foreign_key_type: Int32
  has_many clones : Chinfo, foreign_key_type: Int32, foreign_key: "mirror_id"

  column chidx : Int16
  column schid : String

  column title : String = ""
  column chvol : String = ""

  column w_count : Int32 = 0
  column p_count : Int32 = 0
  column changed_at : Time?

  # # translation

  column vi_title : String = ""
  column vi_chvol : String = ""
  column url_slug : String = ""
  column tl_fixed : Bool = false

  timestamps

  scope :range do |chroot_id, chmin, chmax|
    query = where("chroot_id = ?", chroot_id)
    query.where("chidx >= ?", chmin) if chmin
    query.where("chidx <= ?", chmax) if chmax
    query.order_by(chidx: :asc)
  end

  def initialize(chroot : Chroot, argv : Array(String))
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

    sname, snvid = argv[8], argv[9]
    return if sname == chroot.sname

    mirror_chroot = Chroot.find!({sname: sname, snvid: snvid})
    mirror_chroot.reseed_from_disk! unless mirror_chroot.seeded

    mirror_chidx = argv[10]?.try(&.to_i16) || self.chidx
    self.mirror = Chinfo.find({chroot_id: mirror_chroot.id, chidx: mirror_chidx})
  end

  def translate!(force : Bool = false, cvmtl : MtCore? = nil)
    return if (!force && self.tl_fixed) || (mirror_id_column.defined? && self.mirror_id)
    cvmtl ||= self.chroot.nvinfo.cvmtl

    self.vi_title = cvmtl.cv_title(self.title).to_txt unless self.title.empty?
    self.vi_chvol = cvmtl.cv_title(self.chvol).to_txt unless self.chvol.empty?
    self.url_slug = TextUtil.tokenize(self.vi_title)[0..7].join('-')

    self
  end

  getter chtext : ChText { ChText.load(self.chroot, self.chidx) }

  def text(cpart : Int16 = 0, redo : Bool = false, viuser : Viuser? = nil) : String
    self.mirror.try { |x| return x.text(cpart, redo, viuser) }
    return self.full_text(redo, viuser)[cpart]? || "" unless self.changed_at

    if cached = self.chtext.read(self.schid, cpart)
      text, utime = cached
      self.heal_stats(cpart &+ 1, utime)
    end

    !redo && text ? text : remote_text(redo, viuser).try(&.[cpart]?) || text || ""
  end

  def full_text(redo : Bool = false, viuser : Viuser? = nil) : Array(String)
    if cached = self.chtext.read_full(self.schid)
      parts, utime, w_count = cached
      self.heal_stats(parts.size.to_i16, utime, w_count)
    end

    !redo && parts ? parts : remote_text(redo, viuser) || parts || [] of String
  end

  def save_text(content : Array(String), viuser : Viuser? = nil)
    self.chtext.save(self.schid, content)
    self.p_count = content.size.to_i16
    self.changed_at = Time.utc
    self.viuser = viuser

    self.save!
  end

  def remote_text(redo : Bool = false, viuser : Viuser? = nil)
    chroot = self.chroot
    return unless chroot.is_remote

    ttl = redo ? 1.minutes : 10.years

    remote = RemoteText.new(chroot.sname, chroot.snvid, self.schid, ttl: ttl)

    lines = remote.paras
    lines.unshift(remote.title) unless remote.title.empty?

    self.w_count, output = ChUtil.split_parts(lines)
    self.p_count = output.size
    self.changed_at = Time.utc
    self.viuser = viuser
    self.save!

    self.chtext.save(self.schid, output)
    output
  rescue err
    Log.error(exception: err) { [self.chroot.sname, self.chidx] }
  end

  def heal_stats(p_count : Int16, utime : Time?, w_count = 0)
    self.p_count = p_count if p_count > self.p_count
    self.w_count = w_count if w_count > self.w_count

    self.changed_at = utime if utime && !self.changed_at.try(&.> utime)
    self.save! if self.changed?
  end

  def p_count
    mirror.try(&.p_count) || self.p_count_column.value
  end

  FIELDS = {
    "schid", "title", "chvol", "w_count", "p_count",
    "viuser_id", "mirror_id", "changed_at",
    "vi_title", "vi_chvol", "url_slug",
  }

  def inherit(other : self = self.mirror.not_nil!)
    {% for field in FIELDS %}
      self.{{field.id}} = other.{{field.id}}
    {% end %}
  end

  # after :update, :sync_clones

  # def sync_clones
  #   set = FIELDS.map { |x| "#{x} = excluded.#{x}" }.join(", ")
  #   Chinfo.query.where("mirror_id = ?", self.id).to_update.set(set).execute
  # end

  #############

  ####

  def self.fetch_as_mirror(old_root : Chroot, new_root : Chroot,
                           chmin : Int16 = 0, chmax : Int16? = nil,
                           new_chmin = chmin)
    query = self.query
      .where({chroot_id: old_root.id}).where("chidx >= ?", chmin)
      .order_by(chidx: :asc).select("id, mirror_id, chidx, schid")

    query = query.where("chidx <= ?", chmax) if chmax

    output = [] of self

    query.each do |entry|
      output << new({chroot: new_root,
                     chidx: new_chmin, schid: entry.schid,
                     mirror_id: entry.mirror_id || entry.id})

      new_chmin &+= 1
    end

    output
  end

  def self.bulk_upsert(batch : Array(self), trans : Bool = true, cvmtl : MtCore? = nil) : Nil
    cvmtl ||= batch.first.chroot.nvinfo.cvmtl

    on_conflict = ->(req : Clear::SQL::InsertQuery) do
      req.on_conflict("ON CONSTRAINT chinfos_unique_key").do_update do |upd|
        set = FIELDS.map { |x| "#{x} = excluded.#{x}" }.join(", ")
        upd.set("tl_fixed = 'f', #{set}")
      end
    end

    Clear::SQL.transaction do
      batch.each do |entry|
        entry.translate!(cvmtl: cvmtl) if trans
        entry.save!(on_conflict: on_conflict)
      end
    end
  end

  def self.retranslate(batch : Array(self), cvmtl : MtCore? = nil)
    cvmtl ||= batch.first.chroot.nvinfo.cvmtl
    Clear::SQL.transaction do
      batch.each(&.translate!(cvmtl: cvmtl).try(&.save!))
    end
  end

  def self.nearby_chvol(chroot : Chroot, chidx : Int16) : String
    query.where
      .where("idx <= #{chidx} and chvol <> ''")
      .order_by(chidx: :desc).select("chvol")
      .first.try(&.chvol) || ""
  end

  def self.match_chidx(chroot : Chroot, chidx : Int16) : Int16
    return chidx unless title = get_title(chroot.id, chidx)

    query.where(chroot_id: chroot.id).where(title: title)
      .where("chidx >= #{chidx &- 30}")
      .where("chidx <= #{chidx &+ 30}")
      .order_by(chidx: :desc)
      .select("chidx").first
      .try(&.chidx) || chidx
  end

  def self.get_title(chroot_id : Int64, chidx : Int16)
    return false unless entry = find({chroot_id: chroot_id, chidx: chidx})
    entry.mirror.try(&.title) || entry.title
  end
end
