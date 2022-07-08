module MtlV2::AST
  @[Flags]
  enum NounFlag
    Human
    Place
    Attrb
  end

  enum NounType
    Position
    Locative

    Timeword
    Timespan

    Honorific
    Attribute

    Generic
  end

  enum NameType
    Human
    Place # countries, areas, landscapes names

    Insti # organization
    Affil # combine of Place and Insti

    Title # book title
    Other # other name
  end

  class NounWord < BaseWord
  end

  class NameWord < BaseWord
  end

  enum NounType
    HumanName

    AffilName
    PlaceName
    InstiName

    OtherName
    BookTitle

    Honorific
    Attribute

    Temporal

    Space
    Locat
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

  #####

  class AttriNoun < BaseNoun
  end

  class Temporal < BaseNoun
  end

  class Space < BaseNoun
  end

  class Locat < BaseNoun
  end

  class LocatShang < Locat; end

  class LocatXia < Locat; end

  class LocatZhong < Locat; end

  # -ameba:disable Metrics/CyclomaticComplexity
  def self.noun_from_term(term : V2Term)
    case term.tags[0][1]?
    when nil then BaseNoun.new(term)
    when 'r' then HumanName.new(term)
    when 'n' then AffilName.new(term)
    when 's' then PlaceName.new(term)
    when 't' then InstiName.new(term)
    when 'z' then OtherName.new(term)
    when 'x' then BookTitle.new(term)
    when 'a' then AttriNoun.new(term)
    when 'w' then Honorific.new(term)
      # when 'f' then FamilyName.new(term)
      # when 'l' then NounForm.new(term)
    else BaseNoun.new(term)
    end
  end

  def self.locat_from_term(term : V2Term)
    case term.key
    when "上" then LocatShang.new(term)
    when "下" then LocatXia.new(term)
    when "中" then LocatZhong.new(term)
    else          Locat.new(term)
    end
  end
end
