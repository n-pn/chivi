require "json"
require "../ai_dict"

module MT::AiTerm
  property epos = MtEpos::X
  property attr = MtAttr::None

  property dnum = DictEnum::Unknown_0
  property from = 0

  def fix_epos!(@epos : MtEpos)
    self
  end

  def to_json
    JSON.build { |jb| to_json(jb) }
  end

  def to_json(io : IO) : Nil
    JSON.build(io) { |jb| to_json(jb) }
  end

  abstract def body_to_json(jb : JSON::Builder) : Nil

  def upto
    @zstr.size &+ @from
  end

  def to_json(jb : JSON::Builder) : Nil
    jb.array do
      jb.string @epos
      body_to_json(jb)
      jb.number @from
      jb.number self.upto
      jb.string @attr.none? ? "" : @attr.to_str
      jb.number @dnum.value
    end
  end

  def to_txt(cap : Bool = true, und : Bool = true)
    String.build { |io| to_txt(io, cap: cap, und: und) }
  end

  abstract def to_txt(io : IO, cap : Bool, und : Bool)

  abstract def zstr : String
  abstract def inspect_body(io : IO) : Nil

  def inspect(io : IO, deep = 1) : Nil
    io << '('.colorize.dark_gray
    io << @epos.to_s.colorize.bold
    io << ' ' << @attr unless @attr.none?
    # io << ':' << @_idx
    inspect_body(io, deep: deep)
    io << ')'.colorize.dark_gray
  end
end

class MT::AiWord
  include AiTerm

  property zstr : String
  property body : String

  def initialize(defn : MtTerm, @zstr, epos : MtEpos = :X, attr : MtAttr = :none, @from = 0)
    @epos = defn.fpos.x? ? epos : defn.fpos
    @attr = defn.attr | attr
    @body = defn.vstr
    @dnum = defn.dnum
  end

  def initialize(@epos, @attr, @zstr, @body, @dnum = :autogen_0, @from = 0)
  end

  COLORS = {:green, :yellow, :blue, :red, :cyan, :magenta, :light_gray}

  def inspect_body(io : IO, deep : Int32 = 0) : Nil
    io << ' ' << @zstr.colorize.dark_gray
    io << ' ' << @body.colorize(COLORS[@dnum.value % 10]) unless @dnum.unknown_0?
  end

  @[AlwaysInline]
  def body_to_json(jb : JSON::Builder) : Nil
    jb.string body
  end

  @[AlwaysInline]
  def to_txt(io : IO, cap : Bool, und : Bool)
    io << ' ' unless @attr.undent?(und: und)
    @attr.render_vstr(io, @body, cap: cap, und: und)
  end
end

class MT::AiCons
  include AiTerm

  property zstr : String
  property body : Array(AiTerm)

  def initialize(@epos, @attr, @body,
                 @zstr = body.join(&.zstr),
                 @dnum = :unknown_0,
                 @from = body.first.from)
  end

  @[AlwaysInline]
  def body_to_json(jb : JSON::Builder) : Nil
    jb.array { @body.each(&.to_json(jb)) }
  end

  def to_txt(io : IO, cap : Bool, und : Bool)
    @body.reduce({cap, und}) { |(cap, und), node| node.to_txt(io, cap: cap, und: und) }
  end

  SINGLE_LINES = {"VCD", "VRD", "VNV", "VPT", "VCP", "VAS", "DVP", "QP", "DNP", "DP", "CLP"}

  def inspect_body(io : IO, deep : Int32 = 0) : Nil
    pad_left = @epos.to_s.in?(SINGLE_LINES) ? " " : "\n" + "  " * deep
    @body.each { |node| io << pad_left; node.inspect(io: io, deep: deep &+ 1) }
  end
end
