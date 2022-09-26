require "./adverbial"
require "./adjective"
require "./nominal"
require "./verbal"

module MtlV2::MTL
  class AjnoWord < BaseWord
    getter adjt : AdjtWord { AdjtWord.new(@key, @val, @tab, @idx) }
    getter noun : NounWord { NounWord.new(@key, @val, @tab, @idx) }

    def initialize(term : V2Term, pos = 0)
      super(term, pos)
      @noun = NounWord.new(term, pos &* 2 &+ 1)
      @adjt = AdjtWord.new(term, pos &* 2 &+ 2)
    end
  end

  class AjadWord < BaseWord
    getter adjt : AdjtWord { AdjtWord.new(@key, @val, @tab, @idx) }
    getter advb : AdvbWord { AdvbWord.new(@key, @val, @tab, @idx) }

    def initialize(term : V2Term, pos = 0)
      super(term, pos)
      @advb = AdvbWord.new(term, pos &* 2 &+ 1)
      @adjt = AdjtWord.new(term, pos &* 2 &+ 2)
    end
  end

  class VenoWord < BaseWord
    getter verb : VerbWord { VerbWord.new(@key, @val, @tab, @idx) }
    getter noun : NounWord { NounWord.new(@key, @val, @tab, @idx) }

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)

      @noun = MTL.noun_from_term(term, pos &* 2 + 1)
      @verb = Verbal.from_term(term, pos &* 2 + 2)
    end

    def as_noun!
      self.as!(self.noun)
    end

    def as_verb!
      self.as!(self.verb)
    end
  end

  class VeadWord < BaseWord
    getter verb : VerbWord { VerbWord.new(@key, @val, @tab, @idx) }
    getter advb : AdvbWord { NounWord.new(@key, @val, @tab, @idx) }

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)

      @advb = MTL.advb_from_term(term, pos &* 2 + 1)
      @verb = Verbal.from_term(term, pos &* 2 + 2)
    end

    def as_advb!
      self.as!(self.advb)
    end

    def as_verb!
      self.as!(self.verb)
    end
  end
end
