require "./adjt_kind"

module MtlV2::MTL
  module Adjective
    getter flag = AdjtFlag::None
    forward_missing_to @flag
  end

  class AdjtWord < BaseWord
    include Adjective

    def initialize(term : V2Term, ptag = term.tags[0])
      super(term)
      @flag = AdjtFlag.from(ptag, term.key)
    end
  end
end
