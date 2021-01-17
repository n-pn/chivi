require "colorize"
require "file_utils"

require "./_inits/rm_text"
require "./stores/zip_store"

require "../_oldcv/engine"

class CV::Chtext
  getter seed : String
  getter sbid : String
  getter scid : String
  getter file : String

  property zh_lines : Array(String) { load_zh_text }
  property zh_words : Int32 { zh_lines.map(&.size).sum }
  property zh_mtime = 0_i64

  property cv_trans = ""
  property cv_mtime : Time = Time.unix(0)

  def initialize(@seed, @sbid, @scid)
    @file = "_db/chdata/zhtexts/#{@seed}/#{@sbid}/#{@scid}.txt"
  end

  def fetch!(power = 3) : Nil
    return unless remote?(power)

    puts "fetching!"

    source = RmText.init(@seed, @sbid, @scid)
    @zh_lines = [source.title].concat(source.paras)

    cv_trans = ""
    cv_mtime = Time.unix(0)

    self.save!
  end

  private def remote?(power = 3)
    case @seed
    when "rengshu", "xbiquge",
         "nofff", "5200",
         "biquge5200", "duokan8"
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
      converted = Oldcv::Engine.cv_mixed(zh_lines, dname)
      @cv_trans = converted.map(&.to_s).join("\n")
    end
  end

  def load_zh_text : Array(String)
    store = ZipStore.new("#{File.dirname(@file)}.zip")
    fname = File.basename(@file)

    if zh_text = store.read(fname)
      puts "- <zhtext> [#{@file}] loaded".colorize.green
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

  def save!(file : String = @file) : Nil
    text_dir = File.dirname(file)
    ::FileUtils.mkdir_p(text_dir) unless File.exists?(text_dir)

    File.open(file, "w") { |io| zh_lines.join(io, "\n") }
    puts "- <zhtext> [#{file}] saved.".colorize.yellow
  end

  alias Cache = Hash(String, self)
  CACHE_LIMIT = 512

  @@acache = Cache.new
  @@bcache = Cache.new

  def self.load(seed : String, sbid : String, scid : String)
    label = "#{seed}/#{sbid}/#{scid}"

    unless item = @@acache[label]?
      item = @@bcache[label]? || new(seed, sbid, scid)
      @@acache[label] = item

      if @@acache.size >= CACHE_LIMIT
        @@bcache = @@acache
        @@acache = Cache.new
      end
    end

    item
  end
end
