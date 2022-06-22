module MtlV2::AST
  class Adjt < BaseNode; end

  class Modi < Adjt; end

  class AdjtForm < Adjt; end

  #########

  class AdjtNoun < Mixed
    getter adjt_val : String? = nil
    getter adjt_tag : String = "a"

    getter noun_val : String? = nil
    getter noun_tag : String = "n"

    def initialize(term : V2Term)
      super(term)

      @adjt_val = term.vals[1]?
      @adjt_tag = term.tags[1]? || "a"

      @noun_val = term.vals[2]?
      @noun_tag = term.tags[2]? || "n"
    end
  end

  class AdjtAdvb < Mixed
    getter adjt_val : String? = nil
    getter adjt_tag : String = "a"

    getter advb_val : String? = nil
    getter advb_tag : String = "d"

    def initialize(term : V2Term)
      super(term)

      @adjt_val = term.vals[1]?
      @adjt_tag = term.tags[1]? || "a"

      @noun_val = term.vals[2]?
      @noun_tag = term.tags[2]? || "d"
    end
  end

  class AdjtHao < Mixed
    getter adjt_val = "tốt"
    getter advb_val = "thật"
  end

  ##################

  def self.adjt_from_term(term : V2Term)
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
