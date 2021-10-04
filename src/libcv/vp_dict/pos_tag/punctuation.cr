struct CV::PosTag
  PUNCTS = {
    {"wj", "Pstop", Pos::Puncts},    # full stop of full length: `。`
    {"wx", "Pdeci", Pos::Puncts},    # half stop, decimal `.`
    {"wd", "Comma", Pos::Puncts},    # full or half-length comma: `，` `,`
    {"wn", "Penum", Pos::Puncts},    # full-length enumeration mark: `、`
    {"wm", "Colon", Pos::Puncts},    # full or half-length colon: `：`， `:`
    {"ws", "Ellip", Pos::Puncts},    # full-length ellipsis: …… …
    {"wp", "Pdash", Pos::Puncts},    # dash: ——  －－  —— －  of full length; ---  ---- of half length
    {"wmd", "Middot", Pos::Puncts},  # interpunct
    {"wex", "Exmark", Pos::Puncts},  # full or half-length exclamation mark: `！` `!`
    {"wqs", "Qsmark", Pos::Puncts},  # full or half-length question mark: `？` `?`
    {"wsc", "Smcln", Pos::Puncts},   # full or half-length semi-colon: `；`， `;`
    {"wti", "Tilde", Pos::Puncts},   # tidle ~
    {"wat", "Atsgn", Pos::Puncts},   # at sign @
    {"wps", "Plsgn", Pos::Puncts},   # plus sign +
    {"wms", "Mnsgn", Pos::Puncts},   # minus sign -
    {"wpc", "Perct", Pos::Puncts},   # percentage and permillle signs: ％ and ‰ of full length; % of half length
    {"wqt", "Squanti", Pos::Puncts}, # full or half-length unit symbol ￥ ＄ ￡ ° ℃  $
    {"wyz", "Quoteop", Pos::Puncts}, # full-length single or double opening quote: “ ‘ 『
    {"wyy", "Quotecl", Pos::Puncts}, # full-length single or double closing quote: ” ’ 』
    {"wkz", "Brackop", Pos::Puncts}, # opening brackets: （ 〔 ［ ｛ 【 〖 of full length; ( [ { of half length
    {"wky", "Brackcl", Pos::Puncts}, # closing brackets: ） 〕 ］ ｝ 】 〗 of full length;  ) ] } of half length
    {"wwz", "Titleop", Pos::Puncts}, # open title《〈 ⟨
    {"wwy", "Titlecl", Pos::Puncts}, # close title 》〉⟩
    {"w", "Punct", Pos::Puncts},     # 标点符号 - symbols and punctuations - dấu câu
  }

  @[AlwaysInline]
  def puncts?
    @pos.puncts?
  end
end
