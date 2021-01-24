require "colorize"
require "file_utils"

require "../mapper/zip_store"
require "../source/rm_text"
require "../engine/convert"

class CV::Chtext
  getter s_name : String
  getter snvid : String
  getter schid : String

  getter zh_file : String

  property zh_lines : Array(String) { load_zh_text }
  property zh_words : Int32 { zh_lines.map(&.size).sum }
  property zh_mtime = 0_i64

  property cv_trans = ""
  property cv_mtime = 0_i64

  def initialize(@s_name, @snvid, @schid)
    @zh_file = "_db/chdata/zhtexts/#{@s_name}/#{@snvid}/#{@schid}.txt"
  end

  def fetch!(u_power = 4, expiry = Time.utc - 10.minutes) : Nil
    return unless remote?(u_power)

    source = RmText.init(@s_name, @snvid, @schid, expiry: expiry)
    @zh_lines = [source.title].concat(source.paras)

    cv_trans = ""
    cv_mtime = 0_i64

    self.save_zh!
  end

  private def remote?(u_power = 4)
    case @s_name
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
      cvter.cv_title(zh_lines[0]).to_str(io)

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

  def load_zh_text : Array(String)
    store = ZipStore.new("#{File.dirname(@zh_file)}.zip")
    fname = File.basename(@zh_file)

    if zh_text = store.read(fname)
      puts "- <zh_text> [#{@zh_file}] loaded".colorize.green
      zh_mtime = store.mtime(fname).try(&.to_unix) || 0_i64
      zh_text.split("\n").reject(&.empty?)
    else
      [] of String
    end
  end

  def fix_zh_text! : Nil
    return unless @zh_lines.first?.try(&.includes?('¦'))
    zh_lines.map &.split(/[\tǁ]/).map(&.split('¦', 2)[0]).join
    save!
  end

  def save_zh!(file : String = @zh_file) : Nil
    text_dir = File.dirname(file)
    ::FileUtils.mkdir_p(text_dir) unless File.exists?(text_dir)

    File.open(file, "w") { |io| zh_lines.join(io, "\n") }
    puts "- <zh_text> [#{file}] saved.".colorize.yellow
  end

  alias Cache = Hash(String, self)
  CACHE_LIMIT = 512

  @@acache = Cache.new
  @@bcache = Cache.new

  def self.load(s_name : String, snvid : String, schid : String)
    label = "#{s_name}/#{snvid}/#{schid}"

    unless item = @@acache[label]?
      item = @@bcache[label]? || new(s_name, snvid, schid)
      @@acache[label] = item

      if @@acache.size >= CACHE_LIMIT
        @@bcache = @@acache
        @@acache = Cache.new
      end
    end

    item
  end
end
