module MtlV2::AST
  # ameba:disable Metrics/CyclomaticComplexity
  def self.punct_from_term(term : V2Term)
    case term.key
    when "・", "‧", "•", "·"      then Middot.new(term)
    when "﹐", "，", ","           then Comma.new(term)
    when "﹑", "、", "､"           then EnumComma.new(term)
    when "︰", "∶", "﹕", "：", ":" then Colon.new(term)
    when "⋯", "…", "···", "...",
         "....", ".....", "......" then Ellipsis.new(term)
    when "－", "—", "--", "---" then DashMark.new(term)
    when "."                   then DeciStop.new(term)
    when "。", "｡", "．"         then FullStop.new(term)
    when "！", "﹗", "!"         then ExclaimMark.new(term)
    when "？", "﹖", "?"         then QuestionMark.new(term)
    when "＠", "﹫", "@"         then AtSign.new(term)
    when "；", "﹔", ";"         then Semicolon.new(term)
    when "～", "~"              then TildeMark.new(term)
      # plus sign +
    when "﹢", "＋", "+" then PlusSign.new(term)
      # minus sign -
    when "﹣", "-" then MinusSign.new(term)
      # percentage and permillle signs: ％ and ‰ of full length; % of half length
    when "％", "﹪", "‰", "%" then PercentMark.new(term)
      # full or half-length unit symbol ￥ ＄ ￡ ° ℃  $
    when "￥", "﹩", "＄", "$",
         "￡", "°", "℃" then QuantiMark.new(term)
      # full-length single or double opening quote: “ ‘ 『
    when "『", "「", "“", "‘" then QuoteOpen.new(term)
      # full-length single or double closing quote: ” ’ 』
    when "』", "”", "」", "’" then QuoteStop.new(term)
      # opening parentheses: （ 〔 of full length; ( of half length
    when "｟", "（", "﹙", "(", "〔" then ParenthOpen.new(term)
      # closing parentheses: ） 〕 of full length; ) of half length
    when "｠", "﹚", "）", "〕", ")" then ParenthStop.new(term)
      # opening brackets: （ 〔 ［ ｛ 【 〖 of full length; ( [ { of half length
    when "﹝", "［", "[", "【",
         "〖", "｛", "﹛", "{" then BracketOpen.new(term)
      # closing brackets: ］ ｝ 】 〗 of full length; ] } of half length
    when "﹞", "］", "】", "〗",
         "]", "﹜", "｝", "}" then BracketStop.new(term)
      # open book title《〈 ⟨
    when "《", "〈", "⟨" then TitleOpen.new(term)
      # close book title 》〉⟩
    when "》", "〉", "⟩" then TitleStop.new(term)
    else                    Punct.new(term)
    end
  end

  class Punct < BaseNode
  end

  class OpenPunct < Punct; end

  class StopPunct < Punct; end

  #######

  class Whitespace < BaseNode; end # punctuation
  class Middot < Punct; end

  class Comma < Punct; end

  class EnumComma < Punct; end

  class Colon < Punct; end

  class Ellipsis < Punct; end

  class DashMark < Punct; end

  class DeciStop < Punct; end

  class FullStop < StopPunct; end

  class Semicolon < StopPunct; end

  class ExclaimMark < StopPunct; end

  class QuestionMark < StopPunct; end

  class AtSign < Punct; end

  class TildeMark < Punct; end

  class PlusSign < Punct; end

  class MinusSign < Punct; end

  class PercentMark < Punct; end

  class QuantiMark < Punct; end

  class QuoteOpen < OpenPunct; end

  class QuoteStop < StopPunct; end

  class ParenthOpen < OpenPunct; end

  class ParenthStop < StopPunct; end

  class BracketOpen < OpenPunct; end

  class BracketStop < StopPunct; end

  class TitleOpen < OpenPunct; end

  class TitleStop < StopPunct; end
end
