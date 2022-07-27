require "../mt_base/*"

module MtlV2::MTL
  # ## generic

  @[Flags]
  enum PunctAttr
    # ## generic

    Break # seperate sentence

    Final # mark end of sentence

    Start # open nested group
    Close # close nested group

    Alone # usually punctutation can combine, but for special case they shouldn't

    CapAfter

    NoWspace

    # # singular

    Period
    Exclam
    Questm

    DbQuote
    QuoteSt
    QuoteCl
    TitleSt
    TitleCl
    ParenSt
    ParenCl
    BrackSt
    BrackCl

    Wspace
    Middot

    Colon
    Smcln

    Atsign
    Dashes
    Ellips

    Tilde
    Comma
    Cenum

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
      when "~"           then Tilde
      when "–", "—"      then Dashes
      when "…", "……"     then Ellips | NoWspace
      else                    None
      end
    end
  end

  class PunctWord < BaseWord
    getter attr : PunctAttr
    forward_missing_to @attr

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @attr = PunctAttr.from(term.vals[pos])
      @val = ',' if @attr.cenum?
    end

    def cap_after?(cap : Bool) : Bool
      @attr.cap_after?
    end

    def add_space?
      return !@attr.no_wspace? unless @attr.tilde? && (succ = @succ)
      !succ.attr.includes?(PunctAttr.flags(Final, Close))
    end

    def match_char
      case char = @val[0]
      when '“' then '”'
      when '‘' then '’'
      when '⟨' then '⟩'
      when '<' then '>'
      when '‹' then '›'
      when '(' then ')'
      when '[' then ']'
      when '{' then '}'
      else          char
      end
    end
  end

  module MtNode
    def add_space?(prev : PunctWord)
      !prev.attr.includes?(PunctAttr.flags(Wspace | Start))
    end
  end
end
