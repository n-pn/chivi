require "colorize"

class VpText
  DIR = File.join("data", "vp_texts")

  SEP_0 = "ǁ"
  SEP_1 = "¦"

  def self.root(site : String, bsid : String)
    File.join(DIR, "#{site}.#{bsid}")
  end

  def self.list(site : String, bsid : String, user : String = "local")
    Dir.glob(File.join(root(site, bsid), "*.#{user}.txt"))
  end

  def self.load!(site : String, bsid : String, csid : String, user : String)
    new(site, bsid, csid, user, preload: true)
  end

  getter site : String
  getter bsid : String
  getter csid : String
  getter user : String

  getter root : String
  getter file : String

  property lines = [] of String

  def initialize(@site : String, @bsid : String, @csid : String, @user : String = "local", preload : Bool = true)
    @root = VpText.root(@site, @bsid)
    @file = File.join(@root, "#{@csid}.#{@user}.txt")

    load!(@file) if preload
  end

  def load!(file : String = @file) : VpText
    if File.exists?(file)
      @lines = File.read_lines(file)
      puts "- loaded vp_text `#{file}`".colorize(:cyan)
    else
      puts "- vp_text `#{file}` not found!".colorize(:red)
    end

    self
  end

  def cached?
    File.exists?(@file)
  end

  def to_s(io : IO)
    @lines.join("\n", io)
  end

  def save!(file : String = @file) : VpText
    File.open(file, "w") { |io| to_s(io) }

    self
  end

  def zh_lines : Array(String)
    @lines.map do |line|
      line.split(SEP_0).map { |x| x.split(SEP_1, 2)[0] }.join("")
    end
  end

  def vi_lines : Array(String)
    @lines.map do |line|
      line.split(SEP_0).map { |x| x.split(SEP_1, 3)[1] }.join("")
    end
  end
end
