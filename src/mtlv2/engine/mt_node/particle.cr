require "./_generic"

module MtlV2::MTL
  class PtclWord < BaseWord
  end

  class PtclLe < PtclWord
  end

  class PtclZhi < PtclWord
  end

  class PtclZhe < PtclWord
  end

  class PtclGuo < PtclWord
  end

  class PtclSuo < PtclWord
  end

  class PtclDe1 < PtclWord
  end

  class PtclDe2 < PtclWord
    def as_noun!
      noun = NounWord.new(key: @key, val: "đất", tab: 0, idx: @idx)
      self.bequest!(noun)
    end
  end

  class PtclDe3 < PtclWord
  end

  class PtclDeng < PtclWord
  end

  class PtclDehua < PtclWord
  end

  class PtclYy < PtclWord
  end

  class PtclLs < PtclWord
  end

  class PtclLian < PtclWord
  end

  class Ude1Pair < BasePair
    def initialize(left : BaseNode, ude1 : PtclDe1)
      super(left, ude1, flip: true)
    end

    def noun_prefix?
      false
    end
  end

  class Ude2Pair < BasePair
    def initialize(left : BaseNode, ude2 : PtclDe2)
      super(left, ude2, flip: true)
    end

    def noun_prefix?
      false
    end
  end
end
