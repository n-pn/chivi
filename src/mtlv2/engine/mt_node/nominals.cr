require "./nominals/*"

module MtlV2::MTL
  def self.noun_from_term(term : V2Term, tag = term.tags[0])
    case tag[1]?
    when 'a' then TraitWord.new(term)
    when 's' then PositWord.new(term)
    when 'h' then HonorWord.new(term)
    when 'f' then LocatWord.new(term)
    when 't' then TimeWord.new(term)
    else          NounWord.new(term)
    end
  end

  def self.name_from_term(term : V2Term, tag = term.tags[0])
    case tag[1]?
    when 'r' then HumanName.new(term)
    when 'a' then AffilName.new(term)
      # when 'w' then OtherName.new(term)
    else OtherName.new(term)
    end
  end

  # def self.affil_from_tag(tag : String)
  #   case tags[2]?
  #   when 'l' then Place
  #   when 'g' then Insti
  #   else          Affil
  #   end
  # end

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
