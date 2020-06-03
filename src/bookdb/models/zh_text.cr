require "colorize"

class ZhText
  DIR = File.join("data", "zh_texts")

  def self.root(site : String, bsid : String)
    File.join(DIR, "#{site}-#{bsid}")
  end

  def self.list(site : String, bsid : String)
    Dir.glob(File.join(root(site, bsid), "*.txt"))
  end

  def self.load!(site : String, bsid : String, csid : String)
    new(site, bsid, csid, preload: true)
  end

  getter site : String
  getter bsid : String
  getter csid : String

  getter root : String
  getter file : String

  property lines = [] of String

  def initialize(@site : String, @bsid : String, @csid : String, preload : Bool = false)
    @root = ZhText.root(@site, @bsid)
    @file = File.join(@root, "#{@csid}.txt")

    load!(@file) if preload
  end

  def load!(file : String = @file) : Void
    if File.exists?(file)
      @lines = File.read_lines(file)
      puts "- loaded zh_text file `#{file}`".colorize(:cyan)
    else
      puts "- zh_text file `#{file}` not found!".colorize(:red)
    end
  end

  def cached?
    File.exists?(@file)
  end

  def to_s(io : IO)
    @lines.join("\n", io)
  end

  def save!(file : String = @file) : Void
    File.open(file, "w") { |io| to_s(io) }
  end
end
