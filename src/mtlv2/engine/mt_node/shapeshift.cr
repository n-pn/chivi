require "./nominals"
require "./verbals"
require "./adjectives"
require "./adverbials"

module MtlV2::AST
  module MaybeAdvb
    getter adav : AdvbWord

    def init_noun(term : V2Term, idx : Int32 = 2)
      adav = AdvbWord.new(term, flag: AdvbFlag.from(term.key))
      term.vals[idx].try { |x| adav.val = x }

      adav
    end

    def as_adav!
      @adav.tap(&.replace(self))
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

  module MaybeVerb
    getter verb : VerbWord

    def init_verb(term : V2Term, idx : Int32 = 2)
      verb_tag = term.tags[idx]? || "v"
      verb = VerbWord.new(term, flag: VerbFlag.from(verb_tag, term.key))
      term.vals[idx].try { |x| verb.val = x }

      verb
    end

    def as_verb!
      @verb.tap(&.replace(self))
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
    include MaybeAdjt
    include MaybeAdvb

    def initialize(term : V2Term)
      super(term)
      @adjt = init_adjt(term, idx: 2)
      @adav = init_adav(term, idx: 1)
    end
  end

  class VerbNoun < BaseWord
    include MaybeVerb
    include MaybeNoun

    def initialize(term : V2Term)
      super(term)
      @verb = init_verb(term, idx: 2)
      @noun = init_noun(term, idx: 1)
    end
  end

  class VerbAdvb < BaseWord
    include MaybeVerb
    include MaybeAdvb

    def initialize(term : V2Term)
      super(term)
      @adjt = init_adjt(term, idx: 2)
      @adav = init_adav(term, idx: 1)
    end
  end

  class SuffNoun < BaseWord
  end
end
