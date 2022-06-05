require "./_base"

module CV::POS
  # 动词 - verb - động từ
  struct Verb < Base
    include Contws
    include Verbal

    @[Flags]
    enum Flag
    end
  end

  struct VerbNoun < Base
    include Contws
    include Mixed

    include Verbal
    include Nominal

    getter verb_val : String? = nil
    getter verb_tag : String = "v"

    getter noun_val : String? = nil
    getter noun_tag : String = "n"

    def initialize(@key : String, val : Array(String))
      if (verb_val = val[1]?) && !verb_val.empty?
        verb_val, verb_tag = verb_val.split(" \\", 2)
        @verb_val = verb_val unless verb_val.empty?
        @verb_tag = verb_tag unless verb_tag.empty?
      end

      if (noun_val = val[2]?) && !noun_val.empty?
        noun_val, noun_tag = noun_val.split(" \\", 2)
        @noun_val = noun_val unless noun_val.empty?
        @noun_tag = noun_tag unless noun_tag.empty?
      end
    end

    # def as_noun
    # end
  end

  struct VerbAdv < Base
    include Contws
    include Mixed

    include Verbal
    include Adverbial

    getter verb_val : String? = nil
    getter verb_tag : String = "v"

    getter adv_val : String? = nil
    getter adv_tag : String = "n"

    def initialize(@key : String, val : Array(String))
      if (verb_val = val[1]?) && !verb_val.empty?
        verb_val, verb_tag = verb_val.split(" \\", 2)
        @verb_val = verb_val unless verb_val.empty?
        @verb_tag = verb_tag unless verb_tag.empty?
      end

      if (adv_val = val[2]?) && !adv_val.empty?
        adv_val, adv_tag = adv_val.split(" \\", 2)
        @adv_val = adv_val unless adv_val.empty?
        @adv_tag = adv_tag unless adv_tag.empty?
      end
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init_verb(tag : String, key : String, val = [] of String)
    case tag[1]?
    when nil then Verb.new(key)
    when 'i' then Vintr.new(key)
    when '2' then V2Object.new(key)
    when 'x' then VCombine.new(key)
    when 'p' then VCompare.new(key)
    when 'f' then VDircomp.new(key)
    when 'o' then VerbObject.new(key)
    when 'n' then VerbNoun.new(key, val)
    when 'd' then VerbAdv.new(key)
    when 'm' then parse_vmodal(key)
    when '!' then parse_verb_special(key)
    else          Verb.new(key)
    end
  end
end
