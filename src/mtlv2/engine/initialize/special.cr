module MtlV2::AST
  class UniqNode < BaseNode; end

  class NounPhrase < BaseNode; end

  class VerbPhrase < BaseNode; end

  class DefnPhrase < BaseNode; end

  class PrepClause < BaseNode; end

  class VerbClause < BaseNode; end

  class AdjtClause < BaseNode; end

  def self.extra_from_term(term : V2Term)
    case term.tags[0]
    when "~np" then NounPhrase.new(term)
    when "~vp" then VerbPhrase.new(term)
    when "~ap" then AdjtPhrase.new(term)
    when "~dp" then DefnPhrase.new(term)
    when "~pp" then PrepClause.new(term)
    when "~sv" then VerbClause.new(term)
    when "~sa" then AdjtClause.new(term)
    else            BaseNode.new(term)
    end
  end

  def self.special_from_term(term : V2Term)
    UniqNode.new(term)
  end
end
