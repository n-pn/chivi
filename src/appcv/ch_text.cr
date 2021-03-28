require "file_utils"
require "compress/zip"

require "../libcv/cvmtl"
require "../seeds/rm_chtext"
require "../utils/ram_cache"

class CV::ChText
  DIR = "_db/ch_texts"

  CACHED = RamCache(self).new(512)

  def self.load(bname : String, sname : String, snvid : String,
                chidx : Int32, schid : String)
    CACHED.get("#{sname}/#{snvid}/#{schid}") do
      new(bname, sname, snvid, chidx, schid)
    end
  end

  getter bname : String

  getter sname : String
  getter snvid : String

  getter chidx : Int32
  getter schid : String

  getter zh_text : Array(String)? = nil
  getter cv_data : String? = nil
  getter cv_time : Time = Time.unix(0)

  def initialize(@bname, @sname, @snvid, @chidx, @schid)
    @text_dir = "#{DIR}/#{@sname}/#{@snvid}"
    ::FileUtils.mkdir_p(@text_dir)

    zip_bname = (@chidx // 100).to_s.rjust(3, '0')
    @zip_file = File.join(@text_dir, zip_bname + ".zip")
  end

  def get_cv!(power = 4, mode = 0) : String?
    if @cv_data && mode == 0
      return @cv_data if @cv_time >= Time.utc - cv_ttl(power)
    end

    puts "- <ch_text> [#{@sname}/#{@snvid}/#{@chidx}] converted.".colorize.cyan

    zh_lines = get_zh!(power, reset: mode > 1) || [""]
    @cv_data = convert(zh_lines) || ""
  end

  private def cv_ttl(power = 4)
    case power
    when 0 then 1.week
    when 1 then 1.days
    when 2 then 3.hours
    else        10.minutes
    end
  end

  private def convert(lines : Array(String))
    @cv_time = Time.utc
    return "" if lines.empty?

    String.build do |io|
      mtl = Cvmtl.generic(@bname)
      mtl.cv_title_full(lines[0]).to_str(io)

      1.upto(lines.size - 1) do |i|
        io << "\n"
        para = lines.unsafe_fetch(i)
        mtl.cv_plain(para).to_str(io)
      end
    end
  end

  def get_zh!(power = 4, reset = false)
    @zh_text ||= load_zh!

    if RmSpider.remote?(@sname, power)
      @zh_text = nil if reset || @zh_text.try(&.empty?)
    end

    @zh_text ||= fetch_zh!(reset ? 3.minutes : 3.years) || @zh_text
  end

  def load_zh!
    if File.exists?(@zip_file)
      Compress::Zip::File.open(@zip_file) do |zip|
        next unless entry = zip["#{@schid}.txt"]?
        return entry.open(&.gets_to_end).split('\n')
      end
    end

    [] of String
  end

  def fetch_zh!(valid = 10.years) : Array(String)?
    puller = RmChtext.new(@sname, @snvid, @schid, valid: valid)
    lines = [puller.title].concat(puller.paras)
    lines.tap { |x| save_zh!(x) }
  rescue err
    puts "- Fetch zh_text error: #{err}".colorize.red
  end

  def save_zh!(lines : Array(String)) : Nil
    out_file = File.join(@text_dir, "#{schid}.txt")
    File.open(out_file, "w") { |io| lines.join(io, "\n") }

    puts `zip -jqm "#{@zip_file}" "#{out_file}"`
    puts "- <zh_text> [#{out_file}] saved.".colorize.yellow
  end
end
