require "./_generic"

module MtlV2::AST
  PUNCT_TYPES = {
    {"Space", [" ", "　"]},
    {"Middot", ["・", "‧", "•", "·"]},
    {"PeriodMark", ["。", "｡", "．", "."]},
    {"ExclaimMark", ["！", "﹗", "!"]},
    {"QuestionMark", ["？", "﹖", "?"]},
    {"Comma", ["﹐", "，", ","]},
    {"EnumComma", ["﹑", "、", "､"]},
    {"Colon", ["︰", "∶", "﹕", "：", ":"]},
    {"Ellipsis", ["⋯", "…", "···", "...", "....", ".....", "......"]},
    {"DashMark", ["－", "—", "--", "---"]},
    {"AtSign", ["＠", "﹫", "@"]},
    {"Semicolon", ["；", "﹔", ";"]},
    {"TildeMark", ["～", "~"]},
    {"PlusSign", ["﹢", "＋", "+"]},
    {"MinusSign", ["﹣", "-"]},
    {"QuantiMark", ["￥", "﹩", "＄", "$", "￡", "°", "℃"]},
    {"PercentMark", ["％", "﹪", "‰", "%"]},
    {"SingleQuote", ["'"]},
    {"DoubleQuote", ["\""]},
    {"QuoteOpen", ["『", "「", "“", "‘"]},
    {"QuoteClose", ["』", "”", "」", "’"]},
    {"ParenthOpen", ["｟", "（", "﹙", "〔", "("]},
    {"ParenthClose", ["｠", "）", "﹚", "〕", ")"]},
    {"BracketOpen", ["﹝", "［", "[", "【", "〖", "｛", "﹛", "{"]},
    {"BracketClose", ["﹞", "］", "】", "〗", "]", "﹜", "｝", "}"]},
    {"TitleOpen", ["《", "〈", "⟨"]},
    {"TitleClose", ["》", "〉", "⟩"]},
  }

  enum PunctType
    {% for type in PUNCT_TYPES %}
      {{type[0].id}}
    {% end %}

    Other

    def boundary?
      case self
      when PeriodMark, ExclaimMark, QuestionMark,
           Colon, Semicolon,
           SingleQuote, DoubleQuote,
           QuoteOpen, ParenthOpen, BracketOpen, TitleOpen,
           QuoteClose, ParenthClose, BracketClose, TitleClose
        true
      else false
      end
    end

    def cap_after?
      case self
      when PeriodMark, ExclaimMark, QuestionMark,
           Colon, Space
        true
      else
        false
      end
    end

    def space_before?
      case self
      when DashMark, AtSign, PlusSign, MinusSign,
           QuoteOpen, ParenthOpen, BracketOpen, TitleOpen
        true
      else
        false
      end
    end

    def space_after?
      case self
      when PeriodMark, ExclaimMark, QuestionMark,
           Comma, EnumComma, Colon, Ellipsis,
           DashMark, AtSign, Semicolon, TitleMark,
           PlusSign, MinusSign, QuantiMark, PercentMark,
           QuoteClose, ParenthClose, BracketClose, TitleClose
        true
      else
        false
      end
    end

    def open_group?
      case self
      when QuoteOpen, ParenthOpen, BracketOpen, TitleOpen
        true
      else
        false
      end
    end

    def close_group?
      case self
      when QuoteClose, ParenthClose, BracketClose, TitleClose
        true
      else
        false
      end
    end

    def close_atsign?
      case self
      when Space, Comma, Colon
        true
      else
        false
      end
    end

    #########

    def self.from_key(key : String)
      {% begin %}
      case key
      {% for type in PUNCT_TYPES %}
      case .in?({{type[1]}}) then {{type[0].id}}
      {% end %}
      else Other
      {% end %}
    end
  end

  @[Flags]
  enum PunctFlag
    Ascii

    Boundary
    CapAfter

    SpaceBefore
    SpaceAfter

    OpenGroup
    CloseGroup

    CloseAtsign

    def self.from(key : String, type : PunctType)
      flag = None

      flag |= Ascii if key[0].ascii?
      flag |= Boundary if type.boundary?
      flag |= CapApter if type.cap_apter?
      flag |= SpaceBefore if type.space_before?
      flag |= SpaceAfter if type.space_after?
      flag |= OpenGroup if type.open_group?
      flag |= CloseGroup if type.close_group?
      flag |= CloseAtsign if type.close_atsign?

      flag
    end
  end

  class PunctWord < BaseWord
    getter type : PunctType
    getter flag : PunctFlag

    def initialize(
      term : V2Term,
      @type : PunctType = PunctType.from_key(term.key),
      @flag : PunctFlag = PunctFlag.from(term.key, type)
    )
      super(term)
    end

    def initialize(
      @key : String, @val = key, @idx = 0,
      @type : PunctType = PunctType.from_key(term.key),
      @flag : PunctFlag = PunctFlag.from(term.key, type)
    )
    end
  end
end
