require "colorize"
require "file_utils"
require "compress/zip"

class Oldcv::ChapText
  DIR = "_db/nvdata/zhtexts"
  ::FileUtils.mkdir_p(DIR)

  alias Cache = Hash(String, self)

  CACHE_SIZE = 1024
  @@a_cache = Cache.new
  @@b_cache = Cache.new

  def self.load(seed : String, sbid : String, scid : String)
    file = File.join(DIR, seed, sbid, "#{scid}.txt")

    unless item = @@a_cache[file]?
      item = @@b_cache[file]? || new(file)
      @@a_cache[file] = item

      if @@a_cache.size >= CACHE_SIZE
        @@b_cache = @@a_cache
        @@a_cache = Cache.new
      end
    end

    item
  end

  getter file : String
  property zh_data : Array(String) { load_zh_data }

  property cv_text = ""
  property cv_time = 0_i64

  def initialize(@file : String)
  end

  def load_zh_data
    puts "- <chap_text> loading [#{@file}]".colorize.blue
    return File.read_lines(@file) if File.exists?(@file)

    zip_file = File.dirname(@file) + ".zip"
    if File.exists?(zip_file)
      txt_name = File.basename(@file)

      Compress::Zip::File.open(zip_file) do |zip|
        if content = zip[txt_name]?
          return content.open(&.gets_to_end.split("\n"))
        end
      end
    end

    [] of String
  end

  def save!(file : String = @file) : Nil
    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, zh_data.join("\n"))
    puts "- <chap_text> [#{@file}] saved.".colorize.green
  end
end
