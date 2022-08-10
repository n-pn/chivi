require "sqlite3"

require "./remote/remote_text"

class CV::ChText
  DIR   = "var/chtexts"
  PSIZE = 128

  def self.pgidx(ch_no : Int32) : Int32
    (ch_no &- 1) // PSIZE
  end

  CACHE = {} of String => self

  def self.load(sname : String, s_bid : Int32, ch_no : Int32)
    pg_no = self.pgidx(ch_no)
    CACHE["#{sname}/#{s_bid}/#{pg_no}"] ||= new(sname, s_bid, pg_no)
  end

  #####

  def initialize(sname : String, s_bid : Int32, pg_no : Int32)
    @txt_path = "#{DIR}/#{sname}/#{s_bid}/#{pg_no}"
    @zip_path = @txt_path + ".zip"

    @has_file = File.exists?(@zip_path) || pull_r2!(@zip_path)
  end

  @[AlwaysInline]
  def text_name(s_cid : Int32, cpart : Int = 0)
    "#{s_cid}-#{cpart}.txt"
  end

  def read(s_cid : Int32, cpart : Int16 = 0) : {String, Int64}?
    return unless @has_file

    Compress::Zip::File.open(@zip_path) do |zip|
      return unless entry = zip[text_name(s_cid, cpart)]?
      {entry.open(&.gets_to_end), entry.time.to_unix}
    end
  end

  def read_all(s_cid : Int32, p_len : Int32 = 0) : {Array(String), Int64, Int32}?
    return unless @has_file

    Compress::Zip::File.open(@zip_path) do |zip|
      parts = [] of String
      utime = 0_i64
      c_len = 0

      p_len = 32 if p_len < 1
      p_len.times do |cpart|
        break unless entry = zip[text_name(s_cid, cpart)]?

        etime = entry.time.to_unix
        utime = etime if etime > utime

        ptext = entry.open(&.gets_to_end)
        c_len += ptext.size

        parts << ptext
      end

      {parts, utime, c_len} unless parts.empty?
    end
  end

  def save(s_cid : Int32, parts : Array(String), no_zip : Bool = false)
    return if parts.empty?
    Dir.mkdir_p(@txt_path)

    files = [] of String

    parts.each_with_index do |text, cpart|
      file_path = File.join(@txt_path, text_name(s_cid, cpart))
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

  def pull_r2!(zip_path : String)
    return false unless File.exists?(@txt_path + ".tab")
    R2Client.download(zip_path.sub(DIR, "texts"), zip_path)
  end
end
