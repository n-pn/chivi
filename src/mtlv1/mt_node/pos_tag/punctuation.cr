struct CV::PosTag
  @[Flags]
  enum PunctAttr
    # ## shared

    Break # seperate sentence

    Final # mark end of sentence

    Start # open nested group
    Close # close nested group

    Alone # usually punctutation can combine, but for special case they shouldn't

    CapAfter

    NoWspace

    # # unique

    Period; Exclam; Questm

    # generic double quote/single quote
    DbQuote; SgQuote

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

  PUNCTS = {
    {"Comma", Pos::Puncts, {"﹐", "，", ","}},
    {"Penum", Pos::Puncts, {"﹑", "、", "､"}},
    {"Colon", Pos::Puncts, {"︰", "∶", "﹕", "：", ":"}},
    {"Ellip", Pos::Puncts, {"⋯", "…", "···", "...", "....", ".....", "......"}},
    {"Pdash", Pos::Puncts, {"－", "—", "--", "---"}},
    {"Pdeci", Pos::Puncts, {"."}},
    {"Pstop", Pos::Pstops | Pos::Puncts, {"。", "｡", "．"}},
    {"Exmark", Pos::Pstops | Pos::Puncts, {"！", "﹗", "!"}},
    {"Qsmark", Pos::Pstops | Pos::Puncts, {"？", "﹖", "?"}},
    {"Atsign", Pos::Puncts, {"＠", "﹫", "@"}},
    {"Smcln", Pos::Pstops | Pos::Puncts, {"；", "﹔", ";"}},
    {"Tilde", Pos::Puncts, {"～", "~"}},
    # plus sign +
    {"Plsgn", Pos::Puncts, {"﹢", "＋", "+"}}, # wps
    # minus sign -
    {"Mnsgn", Pos::Puncts, {"﹣", "-"}}, # wms
    # percentage and permillle signs: ％ and ‰ of full length; % of half length
    {"Perct", Pos::Puncts | Pos::Quantis, {"％", "﹪", "‰", "%"}}, # wpc
    # full or half-length unit symbol ￥ ＄ ￡ ° ℃  $
    {"Squanti", Pos::Quantis | Pos::Puncts, {"￥", "﹩", "＄", "$", "￡", "°", "℃"}}, # wqt
    # full-length single or double opening quote: “ ‘ 『
    {"Quoteop", Pos::Popens | Pos::Puncts, {"『", "「", "“", "‘"}}, # wyz
    # full-length single or double closing quote: ” ’ 』
    {"Quotecl", Pos::Pstops | Pos::Puncts, {"』", "”", "」", "’"}}, # wyy
    # opening parentheses: （ 〔 of full length; ( of half length
    {"Parenop", Pos::Popens | Pos::Puncts, {"｟", "（", "﹙", "(", "〔"}}, # wpz
    # closing parentheses: ） 〕 of full length; ) of half length
    {"Parencl", Pos::Pstops | Pos::Puncts, {"｠", "﹚", "）", "〕", ")"}}, # wpy
    # opening brackets: （ 〔 ［ ｛ 【 〖 of full length; ( [ { of half length
    {"Brackop", Pos::Popens | Pos::Puncts, {"﹝", "［", "[", "【", "〖", "｛", "﹛", "{"}}, # wkz
    # closing brackets: ］ ｝ 】 〗 of full length; ] } of half length
    {"Brackcl", Pos::Pstops | Pos::Puncts, {"﹞", "］", "】", "〗", "]", "﹜", "｝", "}"}}, # wky
    # open title《〈 ⟨
    {"Titleop", Pos::Popens | Pos::Puncts, {"《", "〈", "⟨"}}, # wwz
    # close title 》〉⟩
    {"Titlecl", Pos::Pstops | Pos::Puncts, {"》", "〉", "⟩"}}, # wwy
  }

  Punct = new(Tag::Punct, Pos::Puncts, PunctAttr::None)

  def self.parse_punct(str : ::String)
    attr = PunctAttr.from_str(str)

    {% begin %}
      case str
      {% for item in PUNCTS %}
      when .in?({{item[2]}})
        new(Tag::{{item[0].id}}, {{item[1]}}, attr)
      {% end %}
      else
        new(Tag::Punct, Pos::Puncts, attr)
      end
    {% end %}
  end

  @[AlwaysInline]
  def puncts?
    @attr.try(&.is_a?(PunctAttr))
  end

  def puncts?(&block : PunctAttr -> Bool)
    return unless attr = @attr
    yield attr if attr.is_a?(PunctAttr)
  end

  @[AlwaysInline]
  def popens?
    self.puncts?(&.start?)
  end

  @[AlwaysInline]
  def pstops?
    self.puncts?(&.break?)
  end
end
