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
      @attr |= body.attr

      if body.rank > 2 # force single ptag
        @epos = body.epos
      elsif body.epos != epos
        @body = body.as_any(epos)
      end
    when MtNode
      @attr |= body.attr
    end
  end

  @[AlwaysInline]
  def body=(@body : MtDefn)
    @attr = body.attr
  end

  @[AlwaysInline]
  def set_body(vstr : String, dnum : MtDnum = :auto_fix)
    @body = MtDefn.new(vstr, dnum: dnum)
  end

  @[AlwaysInline]
  def body=(vstr : String)
    set_body(vstr, :auto_fix)
  end

  @[AlwaysInline]
  def has_attr?(attr : MtAttr)
    @attr.includes?(attr)
  end

  @[AlwaysInline]
  def attr_off(attr : MtAttr)
    @attr = @attr & ~attr
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

  def reverse_each(& : self ->)
    case body = @body
    when MtDefn
      yield self
    when MtNode
      yield body
    when MtPair
      yield body.tail
      yield body.head
    when Array
      body.reverse_each { |term| yield term }
    end
  end

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

  @[AlwaysInline]
  def to_mtl : String
    String.build { |io| self.to_mtl(io: io) }
  end

  def to_mtl(io : IO) : Nil
    queue = [self] of MtNode

    while node = queue.pop?
      JSON.build(io) do |jb|
        jb.array do
          case body = node.body
          in MtDefn
            jb.string body.vstr
            dnum = 100 &* body.rank &+ body.dnum.value
          in MtNode
            jb.number 1
            queue << body
          in MtPair
            jb.number 2
            if body.flip?
              queue << body.head << body.tail
            else
              queue << body.tail << body.head
            end
          in Array
            jb.number body.size
            body.reverse_each { |node| queue << node }
          end

          jb.number node.from
          jb.number node.upto
          jb.string node.epos
          jb.string node.attr.to_str
          jb.number dnum || 0
        end
      end

      io << '\t'
    end
  end

  @[AlwaysInline]
  def to_json : String
    JSON.build { |jb| self.to_json(jb) }
  end

  @[AlwaysInline]
  def to_json(io : IO) : Nil
    JSON.build(io) { |jb| self.to_json(jb) }
  end

  def to_json(jb : JSON::Builder) : Nil
    jb.max_nesting = 9999
    jb.array do
      jb.string @epos
      jb.string @attr.to_str

      jb.number @from
      jb.number self.upto

      case body = @body
      when MtDefn
        jb.string body.vstr
        jb.number 100 &* body.rank &+ body.dnum.value
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
      io << ' ' << body.vstr.colorize(COLORS[body.dnum.value % 10]? || :dark_gray)
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
      body.each_with_index do |node, i|
        if i > 0
          io << '\n'
          deep.times { io << ' ' }
        else
          io << ' '
        end
        node.inspect(io: io, deep: deep)
      end
    end

    io << ')'.colorize.dark_gray
  end
end
