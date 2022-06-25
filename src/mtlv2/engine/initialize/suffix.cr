module MtlV2::AST
  class Suffix < BaseNode; end

  class SufAdjt < Suffix; end

  class SufNoun < Suffix; end

  class SufVerb < Suffix; end

  def self.suffix_from_term(term : VpTerm)
    case term.tags[0][1]?
    when 'a' then SufAdjt.new(term)
    when 'n' then SufNoun.new(term)
    when 'v' then SufVerb.new(term)
    else          Suffix.new(term)
    end
  end
end
