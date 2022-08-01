require "./remote/remote_text"

class CV::Chtext
  include Clear::Model

  self.table = "chtexts"

  belongs_to chinfo : Chinfo, primary: true, presence: true,
    foreign_key: "chinfo_id", foreign_key_type: Int32

  column content : Array(String)?

  timestamps

  def get(cpart : Int16 = 0, redo : Bool = false, viuser : Viuser? = nil) : String
    if self.content_column.defined? && (content = self.content)
      text = content[cpart]?
    elsif cpart == 0 || cpart < self.chinfo.p_count
      text = load_text_from_disk(cpart)
    end

    return text if !redo && text
    load_text_from_remote(cpart, redo, viuser) || text || ""
  end

  DIR = "var/chtexts"

  def load_text_from_disk(cpart : Int16) : String?
    chinfo = self.chinfo
    chroot = chinfo.chroot

    pgidx = (chinfo.chidx &- 1) // 128
    store = "#{DIR}/#{chroot.sname}/#{chroot.snvid}/#{pgidx}.zip"

    return unless File.exists?(store) || load_store_from_remote(store)

    Compress::Zip::File.open(store) do |zip|
      content = [] of String

      chinfo.p_count.times do |index|
        file_name = "#{chinfo.schid}-#{index}.txt"
        return unless entry = zip[file_name]?
        content << entry.open(&.gets_to_end)
      end

      return if content.empty?
      update({content: content})
      content[cpart]?
    end
  end

  def load_store_from_remote(store : String) : Bool
    if File.exists?(store.sub(".zip", ".tab"))
      return R2Client.download(store.sub(DIR, "texts"), store)
    end

    return false unless self.chinfo.chroot.sname == "jx_la"
    `aws s3 cp "#{store.sub(/^var/, "s3://chivi-bak")}" "#{store}"`
    $?.success?
  end

  def load_text_from_remote(cpart : Int16, redo : Bool = false, viuser : Viuser? = nil) : String?
    chinfo = self.chinfo
    chroot = chinfo.chroot
    return unless chroot.is_remote

    ttl = redo ? 1.minutes : 10.years
    remote = RemoteText.new(chroot.sname, chroot.snvid, chinfo.schid, ttl: ttl)

    # TODO: check for empty title in parser

    lines = remote.paras
    lines.unshift(remote.title) unless remote.title.empty?
    w_count, content = ChUtil.split_parts(lines)

    spawn do
      update({content: content})

      chinfo.update({
        changed_at: Time.utc,
        w_count:    w_count,
        p_count:    content.size,
        viuser:     viuser,
      })
    end

    content[cpart]?
  rescue err
    Log.error(exception: err) { [self.chinfo.schid, self.chinfo.chidx] }
  end

  #####

  def self.find(chinfo : Chinfo)
    if chtext = query.where({chinfo_id: chinfo.id}).select("chinfo_id").first
      chtext.tap(&.chinfo = chinfo)
    else
      new({chinfo: chinfo})
    end
  end

  def self.text(chinfo_id : Int32, cpart : Int16) : String
    Clear::SQL.select("content[#{cpart &+ 1}]")
      .from("chtexts").where("chinfo_id = #{chinfo_id}")
      .scalar(String)
  end
end
