module MtlV2::AST
  enum NounType
    Position
    Locative

    Timeword
    Timespan

    Honorific
    Attribute

    Common
    Proper

    def self.from_tag(tag : String)
      case tag[1]?
      when 't' then Timeword
      when 'f' then Locative
      when 's' then Position
      when 'h' then Honorific
      when 'a' then Attribute
      else          Common
      end
    end
  end

  enum NameType
    Human

    Affil # combine of Place and Insti
    Place # countries, areas, landscapes names
    Insti # organization

    Title # book title
    Other # other name

    def self.from_tag(tag : String)
      case tag[1]?
      when 'r' then Human
      when 'w' then Title
      when 'a' then Affil
      else          Other
      end
    end

    def self.affil_from_tag(tag : String)
      case tags[2]?
      when 'l' then Place
      when 'g' then Insti
      else          Affil
      end
    end
  end

  @[Flags]
  enum NounFlag
    Human
    Place
    Attrb

    def self.from(type : NounType)
      case type
      when .timeword?, .timespan?, .locative?, .attribute?
        Attrb
      when .position?
        Attrb | Place
      when .honorific?
        Human
      else
        None
      end
    end

    def self.from(type : NameType)
      case type
      when .human?
        Human
      when .affil?, .place?, .insti?
        Attrb | Place
      else
        None
      end
    end
  end

  class NounWord < BaseWord
    getter type : NounType
    getter flag : NounFlag

    def initialize(
      term : V2Term,
      @type : NounType = NounType.from_tag(term.tags[0]),
      @flag : NounFlag = NounFlag.from(type)
    )
      super(term)
    end
  end

  class NameWord < BaseWord
    getter type : NameType
    getter flag : NounFlag

    def initialize(
      term : V2Term,
      @type : NameType = NameType.from_tag(term.tags[0]),
      @kind : NounFlag = NounFlag.from(type)
    )
      super(term)
    end
  end

  enum LocatType
    Shang
    Zhong
    Xia
    Other

    def self.from_key(key : String)
      case term.key
      when "上" then Shang
      when "中" then Zhong
      when "下" then Xia
      else          Other
      end
    end
  end

  class LocatVerb < NounWord
    getter kind : LocatType

    def initialize(term : V2Term, kind : LocatType = LocatType.from(term.key))
      super(term, type: :locative)
    end
  end
end
