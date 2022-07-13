require "./nominals"
require "./verbals"
require "./adjectives"
require "./adverbials"

module MtlV2::AST
  module MaybeNoun
    getter noun : NounWord

    def init_noun(term : V2Term, idx : Int32 = 1)
      noun_tag = term.tags[idx]? || "n"

      if noun_tag[0]? == 'n'
        noun = NounWord.new(term, type: NounType.from_tag(noun_tag))
      else
        noun = NameWord.new(term, type: NameType.from_tag(noun_tag))
      end

      term.vals[idx].try { |x| noun.val = x }
      noun
    end

    def as_noun!
      @noun.tap(&.replace(self))
    end
  end

  module MaybeAdjt
    getter adjt : AdjtWord

    def init_adjt(term : V2Term, idx : Int32 = 2)
      adjt_tag = term.tags[idx]? || "a"
      adjt = AdjtWord.new(term, flag: AdjtFlag.from(adjt_tag, term.key))
      term.vals[idx].try { |x| adjt.val = x }

      adjt
    end

    def as_adjt!
      @adjt.tap(&.replace(self))
    end
  end

  module MaybeAdav
    getter adav : AdavWord

    def init_noun(term : V2Term, idx : Int32 = 2)
      adav = AdavWord.new(term, flag: AdavFlag.from(term.key))
      term.vals[idx].try { |x| adav.val = x }

      adav
    end

    def as_adav!
      @adav.tap(&.replace(self))
    end
  end

  class AdjtNoun < BaseWord
    include MaybeNoun
    include MaybeAdjt

    def initialize(term : V2Term)
      super(term)
      @adjt = init_adjt(term, idx: 2)
      @noun = init_noun(term, idx: 1)
    end
  end

  class AdjtAdvb < BaseWord
    def initialize(term : V2Term)
      super(term)
      @adjt = init_adjt(term, idx: 2)
      @adav = init_adav(term, idx: 1)
    end
  end
end
