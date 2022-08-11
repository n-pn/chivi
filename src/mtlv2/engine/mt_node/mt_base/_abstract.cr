require "../../../../libcv/*"

module MtlV2::MTL
  module MtNode
    property tab : Int32 = 0

    property! prev : MtNode
    property! succ : MtNode

    # getter ptag = BasePtag::None

    def set_prev(@prev : Nil) : Nil
    end

    def set_prev(@prev : MtNode) : Nil
      prev.succ = self
    end

    def set_succ(@succ : Nil) : Nil
    end

    def set_succ(@succ : MtNode) : Nil
      succ.prev = self
    end

    def prev?
      @prev.try { |x| yield x }
    end

    def succ?
      @succ.try { |x| yield x }
    end

    def as!(target : MtNode)
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

  module MtSeri
    include MtNode

    abstract def each(&block : MtNode ->)

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

    def inspect(io : IO, pad = -1) : Nil
      pad_space = pad > 0 ? " " * pad : ""

      io << pad_space << '{' << self.klass << '/' << @tab << '}' << '\n'
      each(&.inspect(io, pad + 2))
      io << pad_space << '{' << '/' << self.klass << '}'

      io << '\n' if pad >= 0
    end
  end
end
