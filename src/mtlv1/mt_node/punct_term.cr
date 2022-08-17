require "./mt_term"

@[Flags]
enum CV::PunctAttr
  # ## generic

  Break # seperate sentence

  Final # mark end of sentence

  Start # open nested group
  Close # close nested group

  Alone # usually punctutation can combine, but for special case they shouldn't

  CapAfter

  NoWspace

  # # singular

  Period; Exclam; Questm

  DbQuote # plain double quote

  QuoteSt; QuoteCl
  TitleSt; TitleCl
  ParenSt; ParenCl
  BrackSt; BrackCl

  Wspace
  Middot
  Atsign
  Dashes

  Colon; Smcln
  Comma; Cenum
  Ellip; Tilde

  # ameba:disable Metrics/CyclomaticComplexity
  def self.from_str(str : String)
    case str
    when "."           then Period | Final | Break | CapAfter | NoWspace
    when "!"           then Exclam | Final | Break | CapAfter | NoWspace
    when "?"           then Questm | Final | Break | CapAfter | NoWspace
    when "“", "‘"      then Start | Break
    when "”", "’"      then QuoteCl | Close | Break | NoWspace
    when "⟨", "<", "‹" then TitleSt | Start | CapAfter
    when "⟩", ">", "›" then TitleCl | Close | NoWspace
    when "[", "{"      then BrackSt | Start | CapAfter
    when "]", "}"      then BrackCl | Close | NoWspace
    when "("           then ParenSt | Start
    when ")"           then ParenCl | Close | NoWspace
    when "\""          then DbQuote | Start | Close | NoWspace
    when " "           then Wspace | NoWspace
    when ","           then Comma | NoWspace
    when "､"           then Cenum | NoWspace
    when ":"           then Colon | Break | CapAfter
    when ";"           then Smcln | Break
    when "·"           then Middot
    when "@"           then Atsign
    when "~"           then Tilde | Break
    when "–", "—"      then Dashes | Break
    when "…", "……"     then Ellip | NoWspace
    else                    None
    end
  end
end

class CV::PunctTerm < CV::MtTerm
  getter attr : PunctAttr { PunctAttr.from_str(@key) }
end
