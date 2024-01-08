require "json"
require "../ai_dict"

struct MT::AiPair(T)
  getter head : T
  getter tail : T
  property flip : Bool

  def initialize(@head, @tail, @flip = false)
  end

  def each(& : T ->)
    if @flip
      yield @tail
      yield @head
    else
      yield @head
      yield @tail
    end
  end
end

class MT::AiTerm
  property body : MtDefn | self | AiPair(self) | Array(self)
  property zstr : String = ""

  property epos = MtEpos::X
  property attr = MtAttr::None

  property from = 0
  property upto = 0

  def initialize(@body, @zstr, @epos, @attr : MtAttr = :none, @from = 0)
    case body
    when MtDefn
      @epos = body.fpos unless body.fpos.x?
      @attr |= body.attr
    when AiTerm
      @attr |= body.attr
    end
  end

  def prepend!(term : self) : self
    case body = @body
    in MtDefn
      frag = AiTerm.new(body, zstr: @zstr, epos: :FRAG, from: @from)
      @body = AiPair.new(term, frag)
    in AiTerm
      @body = AiPair.new(term, body)
    in AiPair
      @body = [term, body.head, body.tail]
    in Array(AiTerm)
      body.unshift(term)
    end

    @from = term.from
    self
  end

  @[AlwaysInline]
  def upto : Int32
    @from &+ @zstr.size
  end

  def each_child(& : self ->)
    case body = @body
    when AiTerm
      yield body
    when Array, AiPair
      body.each { |term| yield term }
    end
  end

  @[AlwaysInline]
  def to_txt(cap : Bool = true, und : Bool = true)
    String.build { |io| to_txt(io, cap: cap, und: und) }
  end

  @[AlwaysInline]
  def to_txt(io : IO, cap : Bool, und : Bool)
    case body = @body
    when MtDefn
      io << ' ' unless @attr.undent?(und: und)
      @attr.render_vstr(io, body.vstr, cap: cap, und: und)
    when AiTerm
      body.to_txt(io, cap: cap, und: und)
    else
      self.each_child { |term| cap, und = term.to_txt(io, cap: cap, und: und) }
      {cap, und}
    end
  end

  def to_json : String
    JSON.build { |jb| to_json(jb) }
  end

  def to_json(io : IO) : Nil
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb : JSON::Builder) : Nil
    jb.array do
      jb.string @epos
      jb.string @attr.to_str

      jb.number @from
      jb.number self.upto

      case body = @body
      when MtDefn
        jb.string body.vstr
        jb.number body.dnum.value
      else
        self.each_child(&.to_json(jb: jb))
      end
    end
  end

  COLORS = {:green, :yellow, :blue, :red, :cyan, :magenta, :light_gray}

  def inspect(io : IO, deep : Int32 = 0) : Nil
    io << '('.colorize.dark_gray << @epos.colorize.bold

    deep += @epos.to_s.size + 2

    case body = @body
    when MtDefn
      io << ' ' << @attr.colorize.light_gray unless @attr.none?
      io << ' ' << @zstr.colorize.dark_gray
      io << ' ' << body.vstr.colorize(COLORS[body.dnum.value % 10])
    when AiTerm
      io << ' '
      body.inspect(io: io, deep: deep)
    when AiPair
      io << ' '
      body.head.inspect(io: io, deep: deep)
      io << '\n'
      deep.times { io << ' ' }
      body.tail.inspect(io: io, deep: deep)
    else
      io << ' '
      body.first.inspect(io: io, deep: deep)
      body[1..].each do |term|
        io << '\n'
        deep.times { io << ' ' }
        term.inspect(io: io, deep: deep)
      end
    end

    io << ')'.colorize.dark_gray
  end
end
