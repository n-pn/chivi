require "./noun_kind"
require "../_generics"

module MtlV2::MTL
  module Nominal
    getter kind : NounKind
  end

  class NounWord < BaseWord
    include Nominal

    def initialize(term : V2Term)
      super(term)
      @kind = NounKind::Ktetic
    end
  end

  class TraitWord < NounWord
    def initialize(term : V2Term)
      super(term)
      @kind = NounKind::Abstract
    end
  end

  class PositWord < NounWord
    def initialize(term : V2Term)
      super(term)
      @kind = NounKind::Locale
    end
  end

  class LocatWord < NounWord
    def initialize(term : V2Term)
      super(term)
      @kind = term.key.size > 1 ? NounKind::Locale : NounKind::None
    end
  end

  class HonorWord < NounWord
    def initialize(term : V2Term)
      super(term)
      @kind = NounKind.flags(Ktetic, Person, Individ, Material)
    end
  end

  class TimeWord < NounWord
    def initialize(term : V2Term)
      super(term)
      @kind = NounKind::None
    end
  end

  class HumanName < NounWord
    def initialize(term : V2Term)
      super(term)
      @kind = NounKind.flags(Proper, Person, Ktetic)
    end
  end

  class AffilName < NounWord
    def initialize(term : V2Term)
      super(term)
      @kind = NounKind.flags(Proper, Locale)
    end
  end

  class OtherName < NounWord
    def initialize(term : V2Term)
      super(term)
      @kind = NounKind.flags(Proper, Ktetic)
    end
  end

  # class BookTitle < NounWord
  #   def initialize(term : V2Term)
  #     super(term)
  #     @kind = NounKind.flags(Proper, Ktetic)
  #   end
  # end
end
