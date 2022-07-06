require "./_base_node"
require "./_node_flag"

module MtlV2::AST
  module Puntuation
    getter flag : PunctFlag
  end

  class PunctWord < BaseWord
    include Puntuation

    def initialize(term : V2Term)
      super(term)
      @flag = PunctFlag::Ascii if term.key[0].ascii?
    end
  end

  class Whitespace < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag::CapAfter
    end
  end

  class Middot < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag::CapAfter
    end
  end

  class Comma < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag::SpaceAfter
    end
  end

  class EnumComma < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag::SpaceAfter
    end
  end

  class Colon < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(CapAfter, SpaceAfter, Boundary)
    end
  end

  class Ellipsis < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(SpaceAfter)
    end
  end

  class DashMark < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(CapAfter, SpaceBefore, SpaceAfter)
    end
  end

  class PeriodMark < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(CapAfter, SpaceAfter, Boundary)
    end
  end

  class ExclaimMark < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(CapAfter, SpaceAfter, Boundary)
    end
  end

  class QuestionMark < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(CapAfter, SpaceAfter, Boundary)
    end
  end

  class AtSign < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(SpaceBefore, SpaceAfter)
    end
  end

  class Semicolon < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(SpaceAfter, Boundary)
    end
  end

  class TildMark < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(SpaceAfter)
    end
  end

  class PlusSign < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(SpaceBefore, SpaceAfter)
    end
  end

  class MinusSign < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(SpaceBefore, SpaceAfter)
    end
  end

  class QuantiMark < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(SpaceAfter)
    end
  end

  class PercentMark < PunctWord
    def initialize(term : V2Term)
      super(term)
      @flag |= PunctFlag.flag(SpaceAfter)
    end
  end

  class SingleQuote < PunctWord
  end

  class DoubleQuote < PunctWord
  end

  class OpenPunct < PunctWord
    getter open_char : Char

    def initialize(term : V2Term)
      super(term)

      @open_char = term.key[0]
      @flag |= PunctFlag.flag(SpaceBefore, Boundary)
    end
  end

  class ClosePunct < PunctWord
    getter open_char : Char

    def initialize(term : V2Term)
      super(term)

      @open_char = term.key[0]
      @flag |= PunctFlag.flag(SpaceBefore, Boundary)
    end

    def map_open_char(char : Char)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.punct_from_term(term : V2Term)
    case term.key
    when " ", "　"                then Whitespace.new(term)
    when "・", "‧", "•", "·"      then Middot.new(term)
    when "。", "｡", "．", "."      then PeriodMark.new(term)
    when "！", "﹗", "!"           then ExclaimMark.new(term)
    when "？", "﹖", "?"           then QuestionMark.new(term)
    when "﹐", "，", ","           then Comma.new(term)
    when "﹑", "、", "､"           then EnumComma.new(term)
    when "︰", "∶", "﹕", "：", ":" then Colon.new(term)
    when "⋯", "…", "···", "...",
         "....", ".....", "......" then Ellipsis.new(term)
    when "－", "—", "--", "---" then DashMark.new(term)
    when "＠", "﹫", "@"         then AtSign.new(term)
    when "；", "﹔", ";"         then Semicolon.new(term)
    when "～", "~"              then TildeMark.new(term)
    when "﹢", "＋", "+"         then PlusSign.new(term)
    when "﹣", "-"              then MinusSign.new(term)
    when "￥", "﹩", "＄", "$",
         "￡", "°", "℃"
    when "％", "﹪", "‰", "%"      then PercentMark.new(term)
    when "\""                    then DoubleQuote.new(term)
    when "『", "「", "“", "‘"      then QuoteOpen.new(term)
    when "』", "”", "」", "’"      then QuoteClose.new(term)
    when "｟", "（", "﹙", "〔", "(" then ParentOpen.new(term)
    when "｠", "）", "﹚", "〕", ")" then ParentClose.new(term)
    when "﹝", "［", "[", "【",
         "〖", "｛", "﹛", "{" then BracketOpen.new(term)
    when "﹞", "］", "】", "〗",
         "]", "﹜", "｝", "}" then BracketClose.new(term)
    when "《", "〈", "⟨" then TitleOpen.new(term)
    when "》", "〉", "⟩" then TitleClose.new(term)
    else                    Punct.new(term)
    end
  end
end
