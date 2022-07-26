require "./_base"

module CV::POS
  struct Punctuation < Generic; end # punctuation

  struct PunctOpens < Punctuation; end

  struct PunctStops < Punctuation; end

  #######

  struct Middot < Punctuation; end

  struct Comma < Punctuation; end

  struct Penum < Punctuation; end

  struct Colon < Punctuation; end

  struct Ellip < Punctuation; end

  struct Pdash < Punctuation; end

  struct Pdeci < Punctuation; end

  struct Pstop < PunctStops; end

  struct Smcln < PunctStops; end

  struct Exmark < PunctStops; end

  struct Qsmark < PunctStops; end

  struct Atsign < Punctuation; end

  struct Tilde < Punctuation; end

  struct Plsgn < Punctuation; end

  struct Mnsgn < Punctuation; end

  struct Perct < Punctuation; end

  struct Pquanti < Punctuation; end

  struct Quoteop < PunctOpens; end

  struct Quotecl < PunctStops; end

  struct Parenop < PunctOpens; end

  struct Parencl < PunctStops; end

  struct Brackop < PunctOpens; end

  struct Brackcl < PunctStops; end

  struct Titleop < PunctOpens; end

  struct Titlecl < PunctStops; end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init_punct(key : String)
    case key
    when "・", "‧", "•", "·"      then Middot.new
    when "﹐", "，", ","           then Comma.new
    when "﹑", "、", "､"           then Penum.new
    when "︰", "∶", "﹕", "：", ":" then Colon.new
    when "⋯", "…", "···", "...",
         "....", ".....", "......" then Ellip.new
    when "－", "—", "--", "---" then Pdash.new
    when "."                   then Pdeci.new
    when "。", "｡", "．"         then Pstop.new
    when "！", "﹗", "!"         then Exmark.new
    when "？", "﹖", "?"         then Qsmark.new
    when "＠", "﹫", "@"         then Atsign.new
    when "；", "﹔", ";"         then Smcln.new
    when "～", "~"              then Tilde.new
      # plus sign +
    when "﹢", "＋", "+" then Plsgn.new
      # minus sign -
    when "﹣", "-" then Mnsgn.new
      # percentage and permillle signs: ％ and ‰ of full length; % of half length
    when "％", "﹪", "‰", "%" then Perct.new
      # full or half-length unit symbol ￥ ＄ ￡ ° ℃  $
    when "￥", "﹩", "＄", "$",
         "￡", "°", "℃" then Pquanti.new
      # full-length single or double opening quote: “ ‘ 『
    when "『", "「", "“", "‘" then Quoteop.new
      # full-length single or double closing quote: ” ’ 』
    when "』", "”", "」", "’" then Quotecl.new
      # opening parentheses: （ 〔 of full length; ( of half length
    when "｟", "（", "﹙", "(", "〔" then Parenop.new
      # closing parentheses: ） 〕 of full length; ) of half length
    when "｠", "﹚", "）", "〕", ")" then Parencl.new
      # opening brackets: （ 〔 ［ ｛ 【 〖 of full length; ( [ { of half length
    when "﹝", "［", "[", "【",
         "〖", "｛", "﹛", "{" then Brackop.new
      # closing brackets: ］ ｝ 】 〗 of full length; ] } of half length
    when "﹞", "］", "】", "〗",
         "]", "﹜", "｝", "}" then Brackcl.new
      # open book title《〈 ⟨
    when "《", "〈", "⟨" then Titleop.new
      # close book title 》〉⟩
    when "》", "〉", "⟩" then Titlecl.new
    else                    Punctuation.new
    end
  end
end
