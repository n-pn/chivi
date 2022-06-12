require "../../_util/text_util"

class CV::ChInfo
  class Stats
    property utime : Int64
    property chars : Int32
    property parts : Int32
    property uname : String

    def initialize(@utime = 0_i64, @chars = 0, @parts = 0, @uname = "")
    end

    def initialize(utime : String, chars : String, parts : String, @uname = "")
      @utime = utime.to_i64? || 0_i64
      @chars = chars.to_i? || 0
      @parts = parts.to_i? || 0
    end

    def to_s(io : IO)
      io << '\t' << @utime << '\t' << @chars << '\t' << @parts << '\t' << @uname
    end
  end

  record Proxy, sname : String, snvid : String, chidx : Int32 do
    def to_s(io : IO)
      io << '\t' << @sname << '\t' << @snvid << '\t' << @chidx
    end
  end

  record Trans, title = "", chvol = "", uslug = "" do
    def initialize(@title : String, @chvol : String, @uslug = slugify(title))
    end

    def slugify(title : String)
      tokens = TextUtil.tokenize(title)

      if tokens.size > 8
        tokens.truncate(0, 8)
        tokens[7] = ""
      end

      tokens.join("-")
    end
  end

  property chidx : Int32
  property schid : String

  property title = ""
  property chvol = ""

  property stats : Stats = Stats.new
  property proxy : Proxy? = nil
  property trans = Trans.new("-", "-")

  def initialize(argv : Array(String))
    @chidx = argv[0].to_i
    @schid = argv[1]

    return if argv.size < 4
    @title = argv[2]
    @chvol = argv[3]

    return if argv.size < 7
    @stats = Stats.new(argv[4], argv[5], argv[6], argv[7]? || "")

    return if argv.size < 11
    @proxy = Proxy.new(argv[8], argv[9], argv[10].to_i)
  end

  def initialize(@chidx, @schid = chidx.to_s)
  end

  def initialize(@chidx, @schid, title : String, chvol : String = "")
    set_title!(title, chvol)
  end

  def set_title!(title : String, chvol : String = "")
    @title, @chvol = TextUtil.format_title(title, chvol)
  end

  # delegate empty?, to: @title

  def invalid?
    @title.empty?
  end

  def trans!(cvmtl : MtCore) : self
    @trans = Trans.new(
      title: @title.empty? ? "Thiếu chương" : cvmtl.cv_title(@title).to_s,
      chvol: @chvol.empty? ? "Chính văn" : cvmtl.cv_title(@chvol).to_s
    )

    self
  end

  def exists?
    @stats.chars > 0
  end

  def as_proxy!(sname : String, snvid : String, chidx = self.chidx) : self
    self.dup.tap(&.proxy = Proxy.new(sname, snvid, chidx))
  end

  def inherit!(prev : self) : Void
    return unless self.proxy == prev.proxy && self.schid == prev.schid
    @stats = prev.stats if self.stats.utime < prev.stats.utime
  end

  def changed?(other : self)
    @schid != other.schid || @title != other.title || @chvol != other.chvol
  end

  def to_s(full : Bool = true)
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    return if @title.empty?
    io << @chidx << '\t' << @schid

    io << '\t' << @title << '\t' << @chvol
    return unless @proxy || @stats.utime > 0

    @stats.to_s(io)
    @proxy.try(&.to_s(io))
  end
end
