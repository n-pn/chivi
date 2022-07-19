require "./noun_kind"
require "../_generics"

module MtlV2::MTL
  @[Flags]
  enum NounKind
    # https://khoahoctiengtrung.com/danh-tu-trong-tieng-trung/

    # # in rules

    Ktetic # possessives noun
    Locale # place or location

    # 专有名词
    # https://baike.baidu.com/item/%E4%B8%93%E6%9C%89%E5%90%8D%E8%AF%8D/3543467
    Proper

    Person # noun refer human
    Living # animate noun

    # # future

    # 个体名词 individual noun
    # https://baike.baidu.com/item/%E4%B8%AA%E4%BD%93%E5%90%8D%E8%AF%8D/2894284
    Individ

    # 集体名词 collective Noun
    # https://baike.baidu.com/item/%E9%9B%86%E4%BD%93%E5%90%8D%E8%AF%8D/4368019
    Collect

    # 抽象名词
    # https://baike.baidu.com/item/%E6%8A%BD%E8%B1%A1%E5%90%8D%E8%AF%8D/417488
    Abstract

    # 物质名词
    # https://baike.baidu.com/item/%E7%89%A9%E8%B4%A8%E5%90%8D%E8%AF%8D/10670685
    Material
  end

  module Nominal
    getter kind : NounKind
  end

  module MaybeNoun
    getter noun : NounWord

    def as_noun!
      @noun.tap(&.replace!(self))
    end
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

  # class BookTitle < OtherName
  #   def initialize(term : V2Term)
  #     super(term)
  #     @kind = NounKind.flags(Proper, Ktetic)
  #   end
  # end

  ###########

end
