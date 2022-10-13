module MT::PosTag
  PUNCT_MAP = {
    "."  => make(:period, MtlPos.flags(Boundary, CapAfter, NoWsBefore)),
    "!"  => make(:exclpm, MtlPos.flags(Boundary, CapAfter, NoWsBefore)),
    "?"  => make(:quespm, MtlPos.flags(Boundary, CapAfter, NoWsBefore)),
    "“"  => make(:quote_st1, MtlPos.flags(Boundary, NoWsAfter)),
    "‘"  => make(:quote_st2, MtlPos.flags(Boundary, NoWsAfter)),
    "”"  => make(:quote_cl1, MtlPos.flags(Boundary, NoWsBefore)),
    "’"  => make(:quote_cl2, MtlPos.flags(Boundary, NoWsBefore)),
    "⟨"  => make(:title_st1, MtlPos.flags(Boundary, CapAfter)),
    "<"  => make(:title_st2, MtlPos.flags(Boundary, CapAfter)),
    "‹"  => make(:title_st3, MtlPos.flags(Boundary, CapAfter)),
    "⟩"  => make(:title_cl1, MtlPos.flags(Boundary, NoWsBefore)),
    ">"  => make(:title_cl2, MtlPos.flags(Boundary, NoWsBefore)),
    "›"  => make(:title_cl3, MtlPos.flags(Boundary, NoWsBefore)),
    "["  => make(:brack_st1, MtlPos.flags(Boundary, CapAfter)),
    "{"  => make(:brack_st2, MtlPos.flags(Boundary, CapAfter)),
    "]"  => make(:brack_cl1, MtlPos.flags(Boundary, NoWsBefore)),
    "}"  => make(:brack_cl2, MtlPos.flags(Boundary, NoWsBefore)),
    "("  => make(:paren_st1, MtlPos.flags(Boundary, NoWsAfter)),
    ")"  => make(:paren_cl1, MtlPos.flags(Boundary, NoWsBefore)),
    "\"" => make(:db_quote, MtlPos.flags(Boundary, NoWsBefore)),
    "'"  => make(:sg_quote, MtlPos.flags(Boundary, NoWsBefore)),
    " "  => make(:space, MtlPos.flags(NoWsBefore, NoWsAfter)),
    ","  => make(:comma, MtlPos.flags(NoWsBefore)),
    "､"  => make(:cenum, MtlPos.flags(NoWsBefore, BondWord)),
    ":"  => make(:colon, MtlPos.flags(Boundary, CapAfter, NoWsBefore)),
    ";"  => make(:smcln, MtlPos.flags(Boundary)),
    "·"  => make(:middot, MtlPos.flags(BondWord)),
    "@"  => make(:atsign, MtlPos.flags(NoWsAfter)),
    "~"  => make(:tilde, MtlPos.flags(Boundary)),
    "–"  => make(:dash1, MtlPos.flags(Boundary)),
    "—"  => make(:dash2, MtlPos.flags(Boundary)),
    "…"  => make(:ellip1, MtlPos.flags(NoWsBefore)),
    "……" => make(:ellip2, MtlPos.flags(NoWsBefore)),
  }

  def self.map_punct(str : String)
    PUNCT_MAP[str] ||= make(:punct, :boundary)
  end
end
