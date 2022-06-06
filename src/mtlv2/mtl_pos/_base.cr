module CV::MtlV2::POS
  extend self

  class Phrase
    property key : String = ""
    property val : String = ""

    property idx : Int32 = 0
    property dic : Int32 = 0

    # property tag : PosTag = PosTag::None

    property! form : Phrase # parent node

    property! prev : Phrase
    property! succ : Phrase

    def prev?
      @prev.try { |x| yield x }
    end

    def succ?
      @succ.try { |x| yield x }
    end

    def self.set_prev!(prev : self) : self
      @prev = prev
      prev.succ = self
      self
    end

    def self.set_succ!(succ : self) : self
      @succ = succ
      succ.prev = self
      self
    end

    def to_str
      String.build { |io| to_str(io) }
    end

    def to_str(io : IO)
      io << @val
    end
  end

  class Nested < Phrase
    property! body : Phrase

    def body?
      @body.try { |x| yield x }
    end
  end
end
