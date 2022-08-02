require "./remote/remote_text"

class CV::ChPack
  DIR = "var/chtexts"

  PSIZE = 128_i16

  def self.pgidx(chidx : Int16)
    (chidx &- 1) // PSIZE
  end

  CACHE = {} of Int32 => self

  def self.load(chroot : Chroot, chidx : Int16)
    pgidx = self.pgidx(chidx)
    h_key = chroot.id.unsafe_shl(8) | pgidx
    CACHE[h_key] ||= new(chroot.sname, chroot.snvid, pgidx)
  end

  #####

  def initialize(@sname : String, @snvid : String, @pgidx : Int16)
    @txt_path = "#{DIR}/#{sname}/#{snvid}/#{pgidx}"
    @zip_path = @txt_path + ".zip"
    @has_file = File.exists?(@zip_path) || download_from_cdn(@zip_path)
  end

  @[AlwaysInline]
  def text_name(schid : String, cpart : Int = 0)
    "#{schid}-#{cpart}.txt"
  end

  def read(schid : String, cpart : Int16 = 0)
    return unless @has_file

    Compress::Zip::File.open(@zip_path) do |zip|
      return unless entry = zip[text_name(schid, cpart)]?
      {entry.open(&.gets_to_end), entry.time}
    end
  end

  def save(schid : String, parts : Array(String), no_zip : Bool = false, upload : Bool = false)
    Log.info { parts.size }
    return if parts.empty?
    Dir.mkdir_p(@txt_path)

    parts.each_with_index do |text, cpart|
      file_path = "#{@txt_path}/#{text_name(schid, cpart)}"
      Log.info { file_path }
      File.write(file_path, text)
    end

    pack! unless no_zip
  end

  def pack!
    message = `zip -rjmq "#{@zip_path}" "#{@txt_path}"`
    raise message unless $?.success?
    Dir.delete(@txt_path)
    @has_file = true
  end

  ###
  def download_from_cdn(zip_path : String)
    return false unless File.exists?(zip_path.sub(".zip", ".tab"))
    R2Client.download(zip_path.sub(DIR, "texts"), zip_path)
  end
end

class CV::Chtext
  getter chpack : ChPack

  def initialize(@chinfo : Chinfo, @chroot : Chroot = chinfo.chroot)
    @chpack = ChPack.load(chroot, chinfo.chidx)
  end

  def read(cpart : Int16 = 0, redo : Bool = false, viuser : Viuser? = nil)
    if cached = @chpack.read(@chinfo.schid, cpart)
      text, time = cached
      @chinfo.fix_utime(time)
    end

    !redo && text ? text : load_text_from_remote(redo, viuser).try(&.[cpart]?) || text || ""
  end

  def load_text_from_remote(redo : Bool = false, viuser : Viuser? = nil)
    return unless @chroot.is_remote

    Log.info { "fetch from remote" }

    ttl = redo ? 1.minutes : 10.years
    remote = RemoteText.new(@chroot.sname, @chroot.snvid, @chinfo.schid, ttl: ttl)

    # TODO: check for empty title in parser

    lines = remote.paras
    lines.unshift(remote.title) unless remote.title.empty?

    w_count, output = ChUtil.split_parts(lines)

    @chpack.save(@chinfo.schid, output)
    @chinfo.update!({viuser: viuser, changed_at: Time.utc,
                     w_count: w_count, p_count: output.size})

    output
  rescue err
    Log.error(exception: err) do
      {
        sname: @chroot.sname,
        snvid: @chroot.snvid,
        schid: @chinfo.schid,
        chidx: @chinfo.chidx,
      }
    end
  end
end
