require "json"
require "./mt_defn"

class MT::MtNode
  class ::MT::MtPair
    getter head : MtNode
    getter tail : MtNode
    property? flip : Bool

    def initialize(@head, @tail, @flip = false)
    end

    def each(& : MtNode ->)
      if @flip
        yield @tail
        yield @head
      else
        yield @head
        yield @tail
      end
    end
  end

  property body : MtDefn | self | MtPair | Array(self)
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
    when MtNode
      @attr |= body.attr
    end
  end

  def body=(@body : MtDefn)
    @attr = body.attr
  end

  def body=(vstr : String)
    @body = MtDefn.new(vstr, dnum: :Root2)
  end

  def attr_off(attr : MtAttr)
    @attr = @attr & ~attr
  end

  def prepend!(term : self) : self
    case body = @body
    in MtDefn
      frag = MtNode.new(body, zstr: @zstr, epos: :FRAG, from: @from)
      @body = MtPair.new(term, frag)
    in MtNode
      @body = MtPair.new(term, body)
    in MtPair
      @body = [term, body.head, body.tail]
    in Array(MtNode)
      body.unshift(term)
    end

    @from = term.from
    self
  end

  @[AlwaysInline]
  def upto : Int32
    @from &+ @zstr.size
  end

  def find_by_epos(epos : MtEpos)
    case body = @body
    in MtDefn
      return self if epos == @epos
    in MtNode
      body.epos == epos ? body : body.find_by_epos(epos)
    in Array(MtNode), MtPair
      body.each do |child|
        return child if child.epos == @epos
        child.find_by_epos(epos).try { |found| return found }
      end
    end
  end

  def inner_head
    case body = @body
    in MtDefn then self
    in MtNode then body
    in MtPair then body.head.inner_head
    in Array  then body.first.inner_head
    end
  end

  def inner_tail
    case body = @body
    in MtDefn then self
    in MtNode then body
    in MtPair then body.tail.inner_tail
    in Array  then body.last.inner_tail
    end
  end

  ###

  def each_child(& : self ->)
    case body = @body
    when MtNode
      yield body
    when MtPair
      if body.flip?
        yield body.tail
        yield body.head
      else
        yield body.head
        yield body.tail
      end
    when Array
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
    when MtNode
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
        jb.array do
          self.each_child(&.to_json(jb: jb))
        end
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
    when MtNode
      io << ' '
      body.inspect(io: io, deep: deep)
    when MtPair
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
