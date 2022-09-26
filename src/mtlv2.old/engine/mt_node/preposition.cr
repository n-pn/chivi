require "./_generic"

module MtlV2::MTL
  class PrepWord < BaseWord
  end

  class PrepBa3 < PrepWord
  end

  class PrepBei < PrepWord
  end

  class PrepDui < PrepWord
  end

  class PrepZai < PrepWord
  end

  class PrepBi3 < PrepWord
  end

  # "和"
  class PrepHe2 < PrepWord
  end

  # 跟
  class PrepGen < PrepWord
  end

  #######

  class PrepForm
    include BaseSeri

    getter prep : PrepWord
    getter noun : Nominal

    def initialize(@prep, @noun)
      self.set_prev(prep.prev?)
      self.set_succ(noun.succ?)

      prev.set_prev(nil)
      noun.set_succ(nil)

      @at_end = false
    end

    def postpos?
      @at_end
    end

    def each
      yield prep
      yield noun
    end
  end
end
