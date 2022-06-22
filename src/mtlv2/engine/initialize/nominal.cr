require "./nominal/*"

module MtlV2::AST
  # ameba:disable Metrics/CyclomaticComplexity
  def self.noun_from_term(term : V2term)
    case term.tags[0][1]?
    when nil then BaseNoun.new(term)
    when 'r' then HumanName.new(term)
    when 'n' then AffilName.new(term)
    when 's' then PlaceName.new(term)
    when 't' then IntsiName.new(term)
    when 'z' then OtherName.new(term)
    when 'x' then BookTitle.new(term)
    when 'a' then AttriNoun.new(term)
    when 'w' then Honorific.new(term)
      # when 'f' then FamilyName.new(term)
      # when 'l' then NounForm.new(term)
    else BaseNoun.new(term)
    end
  end

  class BaseNoun < BaseNode
  end

  class HumanName < BaseNoun
  end

  class FamilyName < HumanName
  end

  class AffilName < BaseNoun
  end

  class PlaceName < AffilName
  end

  class InstiName < AffilName
  end

  class OtherName < BaseNoun
  end

  class BookTitle < OtherName
  end

  class Honorific < BaseNoun
  end

  class Temporal < BaseNoun
  end

  class Space < BaseNoun
  end

  class Locat < BaseNoun
  end
end
