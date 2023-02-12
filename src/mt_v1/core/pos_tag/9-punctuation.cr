struct M1::PosTag
  PUNCTS = {
    {"Middot", Pos::Puncts, {"・", "‧", "•", "·"}},
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

  Punct = new(Tag::Punct, Pos::Puncts)

  def self.parse_punct(str : ::String)
    {% begin %}
      case str
      {% for item in PUNCTS %}
      when .in?({{item[2]}})
        new(Tag::{{item[0].id}}, {{item[1]}})
      {% end %}
      else
        new(Tag::Punct, Pos::Puncts)
      end
    {% end %}
  end

  delegate puncts?, to: @pos
  delegate popens?, to: @pos
  delegate pstops?, to: @pos
end
