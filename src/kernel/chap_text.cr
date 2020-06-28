require "colorize"
require "file_utils"

class ChapText
  SEP0 = "ǁ"
  SEP1 = "¦"

  ROOT = File.join("assets", "chaps", "texts")

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
  property data : String = ""

  def initialize(@host : String, @bsid : String, @csid : String, preload : Bool = false)
    @root = ChapText.root(@host, @bsid)
    @file = File.join(@root, "#{@csid}.txt")

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
end
