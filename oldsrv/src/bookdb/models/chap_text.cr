require "colorize"
require "file_utils"

class ChapText
  ROOT = File.join("data", "chaps", "texts")

  def self.setup!
    FileUtils.mkdir_p(ROOT)
  end

  def self.root(host : String, bsid : String)
    File.join(ROOT, "#{host}.#{bsid}")
  end

  def self.glob(host : String, bsid : String)
    Dir.glob(File.join(root(host, bsid), "*.txt"))
  end

  def self.load!(host : String, bsid : String, csid : String)
    new(host, bsid, csid, preload: true)
  end

  getter host : String
  getter bsid : String
  getter csid : String

  getter root : String
  getter file : String

  property lines = [] of String

  def initialize(@host : String, @bsid : String, @csid : String, preload : Bool = false)
    @root = ChapText.root(@host, @bsid)
    @file = File.join(@root, "#{@csid}.txt")

    load!(@file) if preload
  end

  def load!(file : String = @file) : self
    if File.exists?(file)
      @lines = File.read_lines(file)
      puts "- <chap_text> [#{file.colorize(:cyan)}] loaded \
            (#{@lines.size.colorize(:cyan)} lines)."
    else
      puts "- <chap_text> [#{file.colorize(:red)}] not found!"
    end

    self
  end

  def cached? : Bool
    File.exists?(@file)
  end

  def to_s(io : IO)
    @lines.join("\n", io)
  end

  def save!(file : String = @file) : self
    File.open(file, "w") { |io| to_s(io) }
    puts "- <chap_text> [#{file.colorize(:cyan)}] saved."

    self
  end
end
