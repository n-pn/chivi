require "colorize"
require "file_utils"

require "./stores/zip_store"
require "./_inits/rm_text"

require "../engine/convert"

class CV::Chtext
  getter s_name : String
  getter s_nvid : String
  getter s_chid : String

  getter zh_file : String

  property zh_lines : Array(String) { load_zh_text }
  property zh_words : Int32 { zh_lines.map(&.size).sum }
  property zh_mtime = 0_i64

  property cv_trans = ""
  property cv_mtime : Time = Time.unix(0)

  def initialize(@s_name, @s_nvid, @s_chid)
    @zh_file = "_db/chdata/zhtexts/#{@s_name}/#{@s_nvid}/#{@s_chid}.txt"
  end

  def fetch!(power = 3, expiry = Time.utc - 10.years) : Nil
    return unless remote?(power)

    source = RmText.init(@s_name, @s_nvid, @s_chid, expiry: expiry)
    @zh_lines = [source.title].concat(source.paras)

    cv_trans = ""
    cv_mtime = Time.unix(0)

    self.save_zh!
  end

  private def remote?(power = 3)
    case @s_name
    when "rengshu", "xbiquge",
         "nofff", "5200",
         "bqg_5200", "duokan8"
      power > 0
    when "hetushu", "zhwenpg"
      power > 1
    when "shubaow", "69shu", "paoshu8"
      power > 2
    else
      false
    end
  end

  def trans!(dname = "various")
    @cv_mtime = Time.utc

    if zh_lines.empty?
      @cv_trans = ""
    else
      # TODO: replace with new engine
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
  end

  def load_zh_text : Array(String)
    store = ZipStore.new("#{File.dirname(@zh_file)}.zip")
    fname = File.basename(@zh_file)

    if zh_text = store.read(fname)
      puts "- <zh_text> [#{@zh_file}] loaded".colorize.green
      zh_mtime = store.mtime(fname).try(&.to_unix) || 0_i64
      zh_text.split("\n")
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

  def self.load(s_name : String, s_nvid : String, s_chid : String)
    label = "#{s_name}/#{s_nvid}/#{s_chid}"

    unless item = @@acache[label]?
      item = @@bcache[label]? || new(s_name, s_nvid, s_chid)
      @@acache[label] = item

      if @@acache.size >= CACHE_LIMIT
        @@bcache = @@acache
        @@acache = Cache.new
      end
    end

    item
  end
end
