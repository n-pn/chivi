require "./noun_word"

module MtlV2::Engine
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
end
