require "./remote/remote_text"

class CV::Chtext
  include Clear::Model

  self.table = "chtexts"
  primary_key type: :serial

  belongs_to chroot : Chroot, foreign_key_type: Int32

  column chidx : Int16
  column schid : String

  column content : Array(String)?

  timestamps

  def get(cpart : Int16 = 0, redo : Bool = false, viuser : Viuser? = nil) : String
    if content_column.defined?
      text = content.try(&.[cpart]?)
    else
      text = load_text_from_disk(cpart)
    end

    !redo && text ? text : load_text_from_remote(cpart, redo, viuser) || text || ""
  end

  DIR = "var/chtexts"

  def load_text_from_disk(cpart : Int16) : String?
    Log.info { "load from disk".colorize.red }
    chroot = self.chroot

    pgidx = (self.chidx &- 1) // 128
    store = "#{DIR}/#{chroot.sname}/#{chroot.snvid}/#{pgidx}.zip"

    return unless File.exists?(store) || load_store_from_remote(store)

    Compress::Zip::File.open(store) do |zip|
      content = [] of String

      40.times do |index|
        file_name = "#{self.schid}-#{index}.txt"
        break unless entry = zip[file_name]?
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

    return false unless self.chroot.sname == "jx_la"
    `aws s3 cp "#{store.sub(/^var/, "s3://chivi-bak")}" "#{store}"`
    $?.success?
  end

  def load_text_from_remote(cpart : Int16, redo : Bool = false, viuser : Viuser? = nil) : String?
    chroot = self.chroot
    return unless chroot.is_remote

    ttl = redo ? 1.minutes : 10.years
    remote = RemoteText.new(chroot.sname, chroot.snvid, self.schid, ttl: ttl)

    # TODO: check for empty title in parser

    lines = remote.paras
    lines.unshift(remote.title) unless remote.title.empty?
    w_count, content = ChUtil.split_parts(lines)

    spawn do
      update!({content: content})

      if chinfo = Chinfo.find({chroot_id: self.chroot_id, chidx: self.chidx})
        chinfo.update!({
          viuser:     viuser,
          w_count:    w_count,
          p_count:    content.size,
          changed_at: Time.utc,
        })
      end
    end

    content[cpart]?
  rescue err
    Log.error(exception: err) { [self.schid, self.chidx] }
  end

  #####

  def self.bulk_upsert(batch : Array(self)) : Nil
    on_conflict = ->(req : Clear::SQL::InsertQuery) do
      req.on_conflict("ON CONSTRAINT chtexts_unique_key").do_update do |upd|
        upd.set(<<-SQL)
          schid = excluded.schid,
          content = excluded.content,
          updated_at = excluded.updated_at
        SQL
      end
    end

    Clear::SQL.transaction do
      batch.each(&.save!(on_conflict: on_conflict))
    end
  end

  def self.upsert(chinfo : Chinfo)
    upsert(chroot, chinfo.chidx, chinfo.schid)
  end

  def self.upsert(chroot : Chroot, chidx : Int16, schid : String)
    find({chroot_id: chroot.id, chidx: chidx}) || new({chroot: chroot, chidx: chidx, schid: schid})
  end

  def self.text(chroot_id : Int32, chidx : Int16, cpart : Int16) : String
    Clear::SQL.select("content[#{cpart &+ 1}]")
      .from("chtexts").where("chroot_id = #{chroot_id} AND chidx = #{chidx}")
      .scalar(String)
  end
end
