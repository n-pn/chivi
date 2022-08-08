require "sqlite3"

require "./remote/remote_text"

class CV::ChText
  DIR = "var/chtexts"

  PSIZE = 128_i16

  def self.pgidx(chidx : Int16)
    (chidx &- 1) // PSIZE
  end

  CACHE = {} of Int32 => self

  def self.load(chroot : Chroot, chidx : Int16)
    pgidx = self.pgidx(chidx)
    h_key = chroot.id.unsafe_shl(8) | pgidx
    CACHE[h_key] ||= new(chroot.sname, chroot.s_bid, pgidx)
  end

  #####

  def initialize(@sname : String, @s_bid : Int32, @pgidx : Int16)
    @txt_path = "#{DIR}/#{sname}/#{s_bid}/#{pgidx}"
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

  def read_full(schid : String)
    return unless @has_file

    Compress::Zip::File.open(@zip_path) do |zip|
      parts = [] of String
      utime = nil
      w_count = 0

      30.times do |cpart|
        break unless entry = zip[text_name(schid, cpart)]?
        utime = entry.time unless utime.try(&.> entry.time)

        ptext = entry.open(&.gets_to_end)
        parts << ptext

        w_count += ptext.size
      end

      {parts, utime, w_count} unless parts.empty?
    end
  end

  def save(schid : String, parts : Array(String), no_zip : Bool = false, upload : Bool = false)
    return if parts.empty?
    Dir.mkdir_p(@txt_path)

    files = [] of String
    parts.each_with_index do |text, cpart|
      file_path = File.join(@txt_path, text_name(schid, cpart))
      File.write(file_path, text)
      files << file_path
    end

    return if no_zip
    @has_file = true
    return if system("zip", ["-rjmq", @zip_path].concat(files))
    raise "Can't zip texts for some reason!"
  end

  def pack!
    system("zip", {"--include='*.txt'", "-rjmq", @zip_path, @txt_path})
    raise "Can't zip texts" unless $?.success?
    Dir.delete?(@txt_path)
    @has_file = true
  end

  ###
  def download_from_cdn(zip_path : String)
    return false unless File.exists?(zip_path.sub(".zip", ".tab"))
    R2Client.download(zip_path.sub(DIR, "texts"), zip_path)
  end
end
