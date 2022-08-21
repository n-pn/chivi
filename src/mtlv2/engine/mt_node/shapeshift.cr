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
end
