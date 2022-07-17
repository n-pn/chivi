require "./adjt_word"

module MtlV2::Engine
  module MaybeAdjt
    getter adjt : AdjtWord

    def init_adjt(term : V2Term, idx : Int32 = 2)
      adjt = AdjtWord.new(term, term.tags[idx]? || "a")
      term.vals[idx].try { |x| adjt.val = x }
      adjt
    end

    def as_adjt!
      @adjt.tap(&.replace(self))
    end
  end
end
