require "colorize"
require "file_utils"
require "compress/zip"

class ChapText
  # class methods

  DIR = File.join("_db", "prime", "chdata", "texts")
  FileUtils.mkdir_p(DIR)

  # SEP_0 = "ǁ"
  # SEP_1 = "¦"

  alias CACHE_HASH = Hash(String, self)

  CACHE_LIMIT = 1000
  @@back_cache = CACHE_HASH.new
  @@front_cache = CACHE_HASH.new

  def self.load(sname : String, s_bid : String, s_cid : String)
    file = File.join(DIR, sname, s_bid, "#{s_cid}.txt")

    unless item = @@front_cache[file]?
      item = @@back_cache[file]? || new(file)

      @@front_cache[file] = item

      if @@front_cache.size >= CACHE_LIMIT
        @@back_cache = @@front_cache
        @@front_cache = CACHE_HASH.new
      end
    end

    item
  end

  getter file : String
  property zh_data : Array(String) { load_data }

  property cv_text = ""
  property cv_time = 0_i64

  def initialize(@file : String)
  end

  def load_data
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

  # def zh_line(line : String)
  #   line.split(/[\tǁ]/).map(&.split("¦", 2)[0]).join
  # end

  def save!(file : String = @file) : Void
    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, self)

    puts "- <chap_text> [#{@file}] saved.".colorize.green
  end

  def to_s(io : IO)
    zh_data.join(io, "\n")
  end
end
