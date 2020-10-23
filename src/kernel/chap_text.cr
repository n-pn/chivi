require "colorize"
require "file_utils"

class ChapText
  # class methods

  DIR = File.join("_db", "prime", "chdata", "texts")
  FileUtils.mkdir_p(DIR)

  SEP_0 = "ǁ"
  SEP_1 = "¦"

  CACHE = {} of String => ChapText
  LIMIT = 2000

  def self.load(sname : String, s_bid : String, s_cid : String, mode = 1)
    file = File.join(DIR, sname, s_bid, "#{s_cid}.txt")
    CACHE.clear if CACHE.size > LIMIT
    CACHE[file] ||= new(file, mode)
  end

  getter file : String
  property zh_data = [] of String

  property cv_text = ""
  property cv_time = 0_i64

  def initialize(@file, mode : Int32 = 1)
    return if mode == 0
    return unless mode == 2 || File.exists?(@file)
    @zh_data = File.read_lines(file)
  end

  def zh_line(line : String)
    line.split(/[\tǁ]/).map(&.split("¦", 2)[0]).join
  end

  def save!(file : String = @file) : Void
    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, self)
  end

  def to_s(io : IO)
    @zh_data.join(io, "\n")
  end
end
