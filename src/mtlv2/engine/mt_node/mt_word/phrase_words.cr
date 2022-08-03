require "../mt_base/*"

module MtlV2::MTL
  class NounPhrase < BaseWord
  end

  class VerbPhrase < BaseWord
  end

  class AdjtPhrase < BaseWord
  end

  class DefnPhrase < BaseWord
  end

  class PrepClause < BaseWord
  end

  class VerbClause < BaseWord
  end

  class AdjtClause < BaseWord
  end

  def self.phrase_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag
    when "~np" then NounPhrase.new(term, pos: pos)
    when "~vp" then VerbPhrase.new(term, pos: pos)
    when "~ap" then AdjtPhrase.new(term, pos: pos)
    when "~dp" then DefnPhrase.new(term, pos: pos)
    when "~pp" then PrepClause.new(term, pos: pos)
    when "~sv" then VerbClause.new(term, pos: pos)
    when "~sa" then AdjtClause.new(term, pos: pos)
    else            BaseWord.new(term, pos: pos)
    end
  end
end
