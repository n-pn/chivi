require "./_base"

module CV::POS
  struct Adjt < ContentWord; end

  struct Modi < Adjt; end

  struct Adjt < Adjt; end

  struct AdjtPhrase < Adjt; end

  #########

  struct AdjtNoun < Polytag
    getter adjt_val : String? = nil
    getter adjt_tag : String = "a"

    getter noun_val : String? = nil
    getter noun_tag : String = "n"

    def initialize(val : Array(String))
      if (adjt_val = val[1]?) && !adjt_val.empty?
        adjt_val, adjt_tag = adjt_val.split(" \\", 2)
        @adjt_val = adjt_val unless adjt_val.empty?
        @adjt_tag = adjt_tag unless adjt_tag.empty?
      end

      if (noun_val = val[2]?) && !noun_val.empty?
        noun_val, noun_tag = noun_val.split(" \\", 2)
        @noun_val = noun_val unless noun_val.empty?
        @noun_tag = noun_tag unless noun_tag.empty?
      end
    end
  end

  struct AdjtAdvb < Polytag
    getter adjt_val : String? = nil
    getter adjt_tag : String = "a"

    getter advb_val : String? = nil
    getter advb_tag : String = "d"

    def initialize(val : Array(String))
      if (adjt_val = val[1]?) && !adjt_val.empty?
        adjt_val, adjt_tag = adjt_val.split(" \\", 2)
        @adjt_val = adjt_val unless adjt_val.empty?
        @adjt_tag = adjt_tag unless adjt_tag.empty?
      end

      if (advb_val = val[2]?) && !advb_val.empty?
        advb_val, advb_tag = advb_val.split(" \\", 2)
        @advb_val = advb_val unless advb_val.empty?
        @advb_tag = advb_tag unless advb_tag.empty?
      end
    end
  end

  struct AdjtHao < Polytag
    getter adjt_val = "tốt"
    getter advb_val = "thật"
  end

  ##################
  def self.init_adjt(tag : String, key : String, val = [] of String)
    case tag[1]?
    when 'n' then AdjtNoun.new(key, val)
    when 'd' then AdjtAdvb.new(key, val)
    when 'b' then Modi.new
    when 'l' then AdjtPhrase.new
    when 'z' then AdjtPhrase.new
    when 'm' then AMeasure.new
    else          Adjt.new
    end
  end
end
