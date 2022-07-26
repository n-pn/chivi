require "../mt_base/*"

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

  #########

  module Nominal
    # getter kind : NounKind

    def ktetic? : Bool
      false
    end

    def locale? : Bool
      false
    end

    def proper? : Bool
      false
    end

    def person? : Bool
      false
    end

    def living? : Bool
      false
    end

    def abstract? : Bool
      false
    end

    def material? : Bool
      false
    end
  end

  class NounWord < BaseWord
    include Nominal
  end

  module MaybeNoun
    getter noun : NounWord

    def as_noun!
      @noun.tap(&.replace!(self))
    end
  end

  class BasicNoun < NounWord
    def ktetic?
      true
    end

    # def material?
    #   true
    # end
  end

  class AbstrNoun < NounWord
    def abstract?
      true
    end
  end

  class TraitNoun < NounWord
    def abstract?
      true
    end
  end

  class PlaceNoun < NounWord
    def ktetic?
      true
    end

    def locale?
      true
    end

    def material?
      true
    end
  end

  class PositNoun < NounWord
    def locale?
      true
    end
  end

  class LocatNoun < NounWord
    def locale?
      @key.size > 1
    end
  end

  class HonorNoun < NounWord
    getter mold : String

    def initialize(term : V2Term, pos : Int32 = 1)
      super(term)

      if (alt = term.vals[pos]?) && alt.includes?("?")
        @mold = alt
      else
        @mold = "? " + @val
      end
    end

    def apply_honor(name : String)
      @mold.sub("?", name)
    end

    def ktetic?
      true
    end

    def person?
      true
    end

    def material?
      true
    end
  end

  class TimeWord < NounWord
    def adverb?
      @succ.try(&.is_a?(Verbal))
    end
  end

  class HumanName < NounWord
    def ktetic?
      true
    end

    def person?
      true
    end

    def proper?
      true
    end
  end

  class AffilName < NounWord
    def ktetic?
      true
    end

    def locale?
      true
    end

    def proper?
      true
    end
  end

  class OtherName < NounWord
    def ktetic?
      true
    end

    def proper?
      true
    end
  end

  class TitleName < OtherName
  end
end
