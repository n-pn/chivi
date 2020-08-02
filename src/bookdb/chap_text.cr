require "colorize"
require "file_utils"
require "../utils/file_util"

class ChapText
  LABEL = "chap_text"
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  property ubid = ""
  property seed = ""
  property scid = ""
  property type = 0
  # source type, greater than 1 means it can not be fetched remotely

  property data = ""
  property user = ""    # latest converter
  property time = 0_i64 # converted time

  def initialize(@ubid : String, @seed : String, @scid : String, preload : Bool = false)
    @file = File.join(DIR, "#{@ubid}.#{@seed}", "#{@scid}.txt")

    load!(@file) if preload
  end

  def load!(file : String = @file) : self
    if File.exists?(file)
      @data = File.read(file)
      @time = File.info(file).modification_time.to_unix_ms
      puts "- <#{LABEL}> [#{file.colorize.cyan}] loaded."
    else
      puts "- <#{LABEL}> [#{file.colorize.red}] not found!"
    end

    self
  end

  def exists? : Bool
    File.exists?(@file)
  end

  def save!(file : String = @file) : Void
    @time = Time.utc.to_unix_ms
    FileUtils.mkdir_p(File.dirname(file))
    FileUtil.save(file, LABEL, @data.size) { |io| @data.to_s(io) }
  end

  def to_s(io : IO)
    @data.to_s(io)
  end

  def zh_lines : Array(String)
    @data.split("\n").map do |line|
      line.split(SEP_0).map { |x| x.split(SEP_1, 2)[0] }.join("")
    end
  end

  def vi_lines : Array(String)
    @data.split("\n").map do |line|
      line.split(SEP_0).map { |x| x.split(SEP_1, 3)[1] }.join("")
    end
  end

  # class methods

  DIR = File.join("var", "bookdb", "chfiles")
  FileUtils.mkdir_p(DIR)

  def self.path_for(ubid : String, seed : String)
    File.join(DIR, "#{ubid}.#{seed}")
  end

  # extract ubid from file name
  def self.ubid_for(file : String)
    File.basename(File.dirname(file)).split(".").first
  end

  # extract seed from file name
  def self.seed_for(file : String)
    File.basename(File.dirname(file)).split(".").last
  end

  # extract scid from file name
  def self.scid_for(file : String)
    File.basename(file, ".json")
  end

  # load all chap file in folder
  def self.files(ubid : String, seed : String)
    Dir.glob(File.join(path_for(ubid, seed), "*.json"))
  end

  # load all chap scids in folder
  def self.scids(ubid : String, seed : String)
    files(ubid, seed).map { |file| scid_for(file) }
  end

  def self.path_for(ubid : String, seed : String, scid : String)
    File.join(DIR, "#{ubid}.#{seed}", "#{scid}.json")
  end

  def self.load!(ubid : String, seed : String, scid : String)
    new(ubid, seed, scid, preload: true)
  end
end
