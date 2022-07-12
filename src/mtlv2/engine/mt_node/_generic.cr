require "../../../libcv/qtran_util"

module MtlV2::AST
  @[Flags]
  enum BasePtag
    Adjective
    Nominal
    Verbal
  end

  class BaseNode
    property! prev : BaseNode
    property! succ : BaseNode

    getter ptag = BasePtag::None

    def set_prev(@prev : BaseNode) : BaseNode
      prev.succ = self
      self
    end

    def set_prev(@prev : Nil) : BaseNode
      self
    end

    def set_succ(@succ : BaseNode) : BaseNode
      succ.prev = self
      self
    end

    def set_succ(@succ : Nil) : BaseNode
      self
    end

    def prev?
      @prev.try { |x| yield x }
    end

    def succ?
      @succ.try { |x| yield x }
    end

    def tranfer(new_node : BaseNode) : BaseNode
      new_node.set_prev(@prev)
      new_node.set_succ(@succ)
      @prev = @succ = nil
      new_node
    end

    def apply_cap!
      raise "Implemented by chilren"
    end

    def to_txt : String
      String.build { |io| to_txt(io) }
    end

    def to_txt(io : IO) : Nil
      raise "Implemented by chilren"
    end

    def to_mtl : String
      String.build { |io| to_mtl(io) }
    end

    def to_mtl(io : IO) : Nil
      raise "Implemented by chilren"
    end

    def inspect(io : IO) : Nil
      raise "Implemented by chilren"
    end
  end

  class BaseWord < BaseNode
    property idx : Int32 = 0
    property dic : Int32 = 0

    property key : String = ""
    property val : String = ""

    def initialize(@key = "", @val = @key, @dic = 0, @idx = 0)
    end

    def initialize(char : Char, @idx = 0)
      @key = @val = char.to_s
    end

    def initialize(term : V2Term)
      @key = term.key
      @val = term.vals.first
    end

    def dup!(idx : Int32, dic : Int32 = 1) : BaseNode
      target = self.dup
      target.idx = idx
      target.dic = dic
      target
    end

    def apply_cap!(cap : Bool = false) : Bool
      @val = QtranUtil.capitalize(@val) if cap
      false
    end

    def to_txt(io : IO) : Nil
      io << @val
    end

    def to_mtl(io : IO) : Nil
      io << @val << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @key.size
    end

    def inspect(io : IO = STDOUT, pad = -1) : Nil
      io << " " * pad if pad >= 0
      tag = self.class.to_s.sub("MtlV2::AST::", "")
      io << "[#{@key}/#{@val}/#{tag}/#{@dic}/#{@idx}]"
      io << '\n' if pad >= 0
    end
  end

  class BasePair < BaseNode
    property left : BaseNode
    property right : BaseNode

    def initialize(@left : BaseNode, @right : BaseNode, @mark = 0, flip = false)
      raise "Not a close pair" if left.succ? != right

      self.set_prev(left.prev?)
      self.set_succ(right.succ?)

      @left, @right = right, left if flip
    end

    def apply_cap!(cap : Bool = true)
      @left.apply_cap! if cap
      false
    end

    def to_txt(io : IO) : Nil
      @left.to_txt(io)
      io << ' '
      @right.to_txt(io)
    end

    def to_mtl(io : IO) : Nil
      io << '〈' << @mark << '\t'
      @left.to_mtl(io)
      io << '\t'
      @right.to_mtl(io)
      io << '〉'
    end

    def inspect(io : IO, pad = -1) : Nil
      io << " " * pad if pad > 0
      io << '{' << self.class.to_s.sub("MtlV2::AST::", "") << '/' << @mark << ' '

      @left.inspect(io, pad)
      io << ' '
      @right.inspect(io, pad)

      io << '}'
      io << '\n' if pad >= 0
    end
  end

  class BaseList < BaseNode
    getter head : BaseNode
    getter tail : BaseNode

    def initialize(@head : BaseNode, @tail = head, @mark = 0)
      self.set_prev(head.prev?)
      self.set_succ(tail.succ?)
    end

    def add_head(node : BaseNode) : Nil
      self.set_prev(node.prev?)
      node.set_succ(@head)
      @head = node

      node.set_prev(nil)
    end

    def add_tail(node : BaseNode) : Nil
      self.set_succ(node.succ?)
      node.set_prev(@tail)
      @tail = node

      node.set_succ(nil)
    end

    def apply_cap!(cap : Bool = true)
      node = @head

      while node
        cap = node.is_a?(PunctWord) ? node.flag.cap_after? : node.apply_cap!(cap)
        node = node.succ?
      end

      cap
    end

    private def should_space?(left : PunctWord, right : PunctWord)
      left.space_after? || right.space_before?
    end

    private def should_space?(left : PunctWord, right : BaseNode)
      left.space_after?
    end

    private def should_space?(left : BaseNode, right : PunctWord)
      right.space_before?
    end

    private def should_space?(left : BaseNode, right : BaseNode)
      true
    end

    def to_txt(io : IO) : Nil
      node = @head
      node.to_txt(io)

      while succ = node.succ?
        io << ' ' if should_space?(node, succ)
        succ.to_txt(io)
        node = succ
      end
    end

    def to_mtl(io : IO) : Nil
      io << '〈' << @mark << '\t'

      node = @head
      node.to_mtl(io)

      while succ = node.succ?
        io << '\t' if should_space?(node, succ)
        succ.to_mtl(io)
        node = succ
      end

      io << '〉'
    end

    def inspect(io : IO, pad = -1) : Nil
      return unless node = @head
      node.inspect(io, pad &+ 1)

      while succ = node.succ?
        succ.inspect(io, pad &+ 1)
        node = succ
      end
    end
  end
end
