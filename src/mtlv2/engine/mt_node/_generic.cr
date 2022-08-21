require "../../../libcv/*"

module MtlV2::MTL
  module BaseNode
    property tab : Int32 = 0

    property! prev : BaseNode
    property! succ : BaseNode

    # getter ptag = BasePtag::None

    def set_prev(@prev : BaseNode) : Nil
      prev.succ = self
    end

    def set_prev(@prev : Nil) : Nil
    end

    def set_succ(@succ : BaseNode) : Nil
      succ.prev = self
    end

    def set_succ(@succ : Nil) : Nil
    end

    def prev?
      @prev.try { |x| yield x }
    end

    def succ?
      @succ.try { |x| yield x }
    end

    def as!(target : BaseNode)
      target.set_prev(@prev)
      target.set_succ(@succ)
      @prev = @succ = nil
      target
    end

    def unlink!
      @prev = @succ = nil
    end

    abstract def apply_cap! : Bool
    abstract def to_txt(io : IO) : Nil
    abstract def to_mtl(io : IO) : Nil
    abstract def inspect(io : IO) : Nil

    def add_space?(prev : Nil)
      false
    end

    def add_space?(prev : BaseWord)
      prev.val != ""
    end

    def add_space?(prev)
      true
    end

    def to_txt : String
      String.build { |io| to_txt(io) }
    end

    def to_mtl : String
      String.build { |io| to_mtl(io) }
    end

    def klass
      self.class.to_s.sub("MtlV2::MTL::", "")
    end
  end

  class BaseWord
    include BaseNode

    property key : String = ""
    property val : String = ""
    property idx : Int32 = 0

    def initialize(@key = "", @val = @key, @tab : Int32 = 0, @idx : Int32 = 0)
    end

    def initialize(term : V2Term, pos : Int32 = 0)
      @key = term.key

      while pos > 0
        break if val = term.vals[pos]?
        pos = (pos &- 1) // 2
      end

      @val = val || term.vals[0]
    end

    def dup!(idx : Int32, tab : Int32 = 1) : BaseNode
      res = self.dup
      res.idx = idx
      res.tab = tab
      res
    end

    def apply_cap!(cap : Bool = false) : Bool
      @val = QtranUtil.capitalize(@val) if cap
      false
    end

    def to_txt(io : IO) : Nil
      io << @val
    end

    def to_mtl(io : IO) : Nil
      io << @val << 'ǀ' << @tab << 'ǀ' << @idx << 'ǀ' << @key.size
    end

    def inspect(io : IO = STDOUT, pad : Int32 = -1) : Nil
      io << " " * pad if pad > 0
      io << "#{self.klass}[#{@key}/#{@val}]"
      io << '\n' if pad >= 0
    end
  end

  #####

  module BaseSeri
    include BaseNode

    abstract def each(&block : BaseNode -> Nil)

    def apply_cap!(cap : Bool = true) : Bool
      each { |x| cap = x.apply_cap!(cap) }
      cap
    end

    def to_txt(io : IO) : Nil
      prev = nil

      each do |node|
        io << ' ' if node.add_space?(prev)
        node.to_txt(io)
        prev = node
      end
    end

    def to_mtl(io : IO) : Nil
      io << '〈' << @tab << '\t'
      prev = nil

      each do |node|
        io << "\t " if node.add_space?(prev)
        node.to_mtl(io)
        prev = node
      end

      io << '〉'
    end

    def inspect(io : IO, pad : Int32 = -1) : Nil
      pad_space = pad > 0 ? " " * pad : ""
      io << pad_space << '{' << self.klass << '/' << @tab << '}' << '\n'
      each(&.inspect(io, pad &+ 2))
      io << pad_space << '{' << '/' << self.klass << '}'
      io << '\n' if pad >= 0
    end
  end

  class BasePair
    include BaseSeri

    property left : BaseNode
    property right : BaseNode

    def initialize(@left : BaseNode, @right : BaseNode, @flip = false)
      self.set_prev(left.prev?)
      self.set_succ(right.succ?)

      if flip
        @left = right
        @right = left
        @left.set_succ(@right)
      end

      @left.set_prev(nil)
      @right.set_succ(nil)
    end

    def each
      yield left
      yield right
    end

    def detact!
      left, right = flip ? {@right, @left} : {@left, @right}

      right.set_succ(@succ)
      left.set_prev(@prev)

      left.set_succ(right)
      @prev = @succ = nil

      {left, right}
    end
  end

  class BaseExpr
    include BaseSeri

    property head : BaseNode
    property tail : BaseNode

    def initialize(@head : BaseNode, @tail : BaseNode, flip : Bool = false, @tab : Int32 = 0)
      self.set_prev(head.prev?)
      self.set_succ(tail.succ?)

      if flip
        @tail = tail.prev
        @head = tail
        @head.set_succ(head)
      end

      @head.set_prev(nil)
      @tail.set_succ(nil)
    end

    def initialize(orig : BaseExpr, @tab : Int32 = orig.tab)
      @head, @tail = orig.head, orig.tail
      set_prev(orig.prev?)
      set_succ(orig.succ?)
    end

    def add_head(node : BaseNode) : Nil
      self.set_prev(node.prev?)
      node.set_prev(nil)

      node.set_succ(@head)
      @head = node
    end

    def add_tail(node : BaseNode) : Nil
      self.set_succ(node.succ?)
      node.set_succ(nil)

      node.set_prev(@tail)
      @tail = node
    end

    def each
      yield @head
      node = @head

      while node = node.succ?
        yield node
      end
    end
  end
end
