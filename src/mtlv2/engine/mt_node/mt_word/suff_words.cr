require "../mt_base/*"

module MtlV2::MTL
  class SuffWord < BaseWord
  end

  class SuffElse < SuffWord
  end

  class UzhiSuff < SuffWord
  end

  class PostWord < SuffWord
  end

  def self.suffix_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[1]?
    when 'x' then SuffElse.new(term, pos: pos)
      # when '!' then # parse speical suffix here
    else SuffWord.new(term, pos: pos)
    end
  end
end
