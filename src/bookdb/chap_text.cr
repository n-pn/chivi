require "colorize"
require "file_utils"

class ChapText
  SEP0 = "ǁ"
  SEP1 = "¦"

  property type = 0
  property ubid = ""
  property seed = ""
  property scid = ""
  property data = ""

  property converted_at = 0_i64
  property converted_by = ""

  def initialize(@ubid : String, @seed : String, @scid : String, preload : Bool = false)
    @root = ChapText.root(@ubid, @seed)
    @file = File.join(@root, "#{@scid}.txt")

    load!(@file) if preload
  end

  def load!(file : String = @file) : self
    if File.exists?(file)
      @data = File.read(file)
      puts "- <chap_text> [#{file.colorize(:cyan)}] loaded."
    else
      puts "- <chap_text> [#{file.colorize(:red)}] not found!"
    end

    self
  end

  def exists? : Bool
    File.exists?(@file)
  end

  def save!(file : String = @file) : self
    File.write(file, @data)
    puts "- <chap_text> [#{file.colorize(:cyan)}] saved."

    self
  end

  def to_s(io : IO)
    io << @data
  end

  def zh_lines : Array(String)
    @data.split("\n").map do |line|
      line.split(SEP0).map { |x| x.split(SEP1, 2)[0] }.join("")
    end
  end

  def vi_lines : Array(String)
    @data.split("\n").map do |line|
      line.split(SEP0).map { |x| x.split(SEP1, 3)[1] }.join("")
    end
  end

  # class methods

  DIR = File.join("var", "chapdb", "files")
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
