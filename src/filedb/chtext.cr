require "colorize"
require "file_utils"

require "../mapper/zip_store"
require "../source/rm_chtext"
require "../engine/convert"

class CV::Chtext
  getter sname : String
  getter snvid : String
  getter schid : String

  getter zh_file : String

  property zh_lines : Array(String) { load_zhtext }
  property zh_words : Int32 { zh_lines.map(&.size).sum }

  property cv_trans = ""
  property cv_mtime = 0_i64

  def initialize(@sname, @snvid, @schid)
    @zh_file = "_db/chdata/zhtexts/#{@sname}/#{@snvid}/#{@schid}.txt"
  end

  def fetch!(u_power = 4, ttl = 3.minutes) : Nil
    return unless remote?(u_power)
    puts "FETCHING!"

    puller = RmChtext.new(@sname, @snvid, @schid, ttl: ttl)
    @zh_lines = [puller.title].concat(puller.paras)

    cv_trans = ""
    cv_mtime = 0_i64

    self.save_zh!
  rescue err
    puts "- Fetch chtext error: #{err}".colorize.red
  end

  private def remote?(u_power = 4)
    case @sname
    when "_chivi", "_miscs", "zxcs_me", "zadzs"
      false
    when "5200", "bqg_5200", "rengshu", "nofff"
      true
    when "xbiquge", "duokan8", "hetushu"
      u_power > 0
    when "zhwenpg", "69shu", "paoshu8"
      u_power > 1
    when "shubaow"
      u_power > 2
    else
      u_power > 3
    end
  end

  def trans!(dname = "various")
    @cv_mtime = Time.utc.to_unix
    return if zh_lines.empty?

    cvter = Convert.generic(dname)

    @cv_trans = String.build do |io|
      cvter.cv_title_full(zh_lines[0]).to_str(io)

      1.upto(zh_lines.size - 1) do |i|
        io << "\n"
        para = zh_lines.unsafe_fetch(i)
        cvter.cv_plain(para).to_str(io)
      end
    end
  end

  def translated?(time = Time.utc - 3.hours)
    @cv_mtime >= time.to_unix
  end

  def load_zhtext : Array(String)
    store = ZipStore.new("#{File.dirname(@zh_file)}.zip")
    fname = File.basename(@zh_file)

    if input = store.read(fname)
      puts "- <zh_text> [#{@zh_file}] loaded".colorize.green
      fix_zhtext!(input.split("\n"))
    else
      [] of String
    end
  end

  def fix_zhtext!(lines : Array(String) = zh_lines) : Array(String)
    lines = lines.reject(&.empty?)
    return lines unless lines.first?.try(&.includes?('¦'))

    lines = lines.map do |line|
      line.split(/[\tǁ]/).map(&.split('¦', 2)[0]).join
    end

    save_zh!(lines: lines)
    lines
  end

  def save_zh!(file : String = @zh_file, lines = zh_lines) : Nil
    text_dir = File.dirname(file)
    ::FileUtils.mkdir_p(text_dir) unless File.exists?(text_dir)

    File.open(file, "w") { |io| lines.join(io, "\n") }
    puts "- <zh_text> [#{file}] saved.".colorize.yellow
  end

  alias Cache = Hash(String, self)
  CACHE_LIMIT = 256

  @@acache = Cache.new
  @@bcache = Cache.new

  def self.load(sname : String, snvid : String, schid : String)
    label = "#{sname}/#{snvid}/#{schid}"

    unless item = @@acache[label]?
      item = @@bcache[label]? || new(sname, snvid, schid)
      @@acache[label] = item

      if @@acache.size >= CACHE_LIMIT
        @@bcache = @@acache
        @@acache = Cache.new
      end
    end

    item
  end
end
