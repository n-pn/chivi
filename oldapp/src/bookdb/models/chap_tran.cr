require "colorize"

class ChapTran
  SEP0 = "ǁ"
  SEP1 = "¦"
  ROOT = File.join("data", "chaps", "trans")

  def self.setup!
    FileUtils.mkdir_p(ROOT)
  end

  def self.root(host : String, bsid : String)
    File.join(ROOT, "#{host}.#{bsid}")
  end

  def self.list(host : String, bsid : String, user : String = "local")
    Dir.glob(File.join(root(host, bsid), "*.#{user}.txt"))
  end

  def self.load!(host : String, bsid : String, csid : String, user : String)
    new(host, bsid, csid, user, preload: true)
  end

  getter host : String
  getter bsid : String
  getter csid : String
  getter user : String

  getter root : String
  getter file : String

  property lines = [] of String

  def initialize(@host : String, @bsid : String, @csid : String, @user : String = "local", preload : Bool = true)
    @root = ChapTran.root(@host, @bsid)
    @file = File.join(@root, "#{@csid}.#{@user}.txt")

    load!(@file) if preload
  end

  def load!(file : String = @file) : ChapTran
    if File.exists?(file)
      @lines = File.read_lines(file)
      puts "- <chap_tran> [#{file.colorize(:cyan)}] loaded \
            (#{@lines.size.colorize(:cyan)} lines)."
    else
      puts "- <chap_tran> [#{file.colorize(:red)}] not found!"
    end

    self
  end

  def cached?
    File.exists?(@file)
  end

  def to_s(io : IO)
    @lines.join("\n", io)
  end

  def save!(file : String = @file) : ChapTran
    File.open(file, "w") { |io| to_s(io) }

    self
  end

  def zh_lines : Array(String)
    @lines.map do |line|
      line.split(SEP0).map { |x| x.split(SEP1, 2)[0] }.join("")
    end
  end

  def vi_lines : Array(String)
    @lines.map do |line|
      line.split(SEP0).map { |x| x.split(SEP1, 3)[1] }.join("")
    end
  end
end
