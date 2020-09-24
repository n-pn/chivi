require "colorize"
require "file_utils"

require "../../utils/file_util"

class ChapText
  # class methods

  DIR = File.join("var", "appcv", "chtexts")
  FileUtils.mkdir_p(DIR)

  SEP_0 = "ǁ"
  SEP_1 = "¦"

  CACHE = {} of String => ChapText
  LIMIT = 5000

  def self.load(ubid : String,
                seed : String,
                sbid : String,
                scid : String,
                mode : Int32 = 1)
    file = File.join(DIR, "#{ubid}.#{seed}/#{sbid}.#{scid}.txt")
    CACHE.shift if CACHE.size > LIMIT
    CACHE[file] ||= new(file, mode)
  end

  getter file : String
  property zh_data = [] of String

  property cv_text = ""
  property cv_time = 0_i64

  def initialize(@file, mode : Int32 = 1)
    return if mode == 0
    return unless mode == 2 || File.exists?(@file)

    dirty = false

    File.each_line(file) do |line|
      if dirty
        @zh_data << zh_line(line)
      elsif line =~ /[\tǁ]/
        dirty = true
        @zh_data << zh_line(line)
      else
        @zh_data << line
      end
    end

    save!(@file) if dirty
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
