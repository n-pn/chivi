require "colorize"
require "file_utils"
require "./stores/zip_store"

class CV::Chtext
  alias Cache = Hash(String, self)
  CACHE_LIMIT = 512

  @@acache = Cache.new
  @@bcache = Cache.new

  def self.load(seed : String, sbid : String, scid : String)
    file = "_db/nvdata/chtexts/#{seed}/#{sbid}/#{scid}.txt"

    unless item = @@acache[file]?
      item = @@bcache[file]? || new(file)
      @@acache[file] = item

      if @@acache.size >= CACHE_LIMIT
        @@bcache = @@acache
        @@acache = Cache.new
      end
    end

    item
  end

  getter file : String
  property zh_lines : Array(String) { load_zh_text }
  property cv_trans = ""
  property cv_mtime = 0_i64

  def initialize(@file : String)
    @dir = File.dirname(@file)
  end

  def load_zh_text : Array(String)
    if zh_text = ZipStore.read("#{@dir}.zip", @file)
      puts "- <chtext> [#{@file}] loaded".colorize.green
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
    ::FileUtils.mkdir_p(@dir) unless File.exists(@dir)
    File.open(file, "w") { |io| @zh_lines.join(io, "\n") }
    puts "- <chtext> [#{file}] saved.".colorize.yellow
  end
end
