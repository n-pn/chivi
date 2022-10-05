struct CV::PosTag
  PUNCT_MAP = {
    "."  => new(:period, MtlPos.flags(Boundary, CapAfter, NoWsBefore)),
    "!"  => new(:exclpm, MtlPos.flags(Boundary, CapAfter, NoWsBefore)),
    "?"  => new(:quespm, MtlPos.flags(Boundary, CapAfter, NoWsBefore)),
    "“"  => new(:quote_st1, MtlPos.flags(Boundary, NoWsAfter)),
    "‘"  => new(:quote_st2, MtlPos.flags(Boundary, NoWsAfter)),
    "”"  => new(:quote_cl1, MtlPos.flags(Boundary, NoWsBefore)),
    "’"  => new(:quote_cl2, MtlPos.flags(Boundary, NoWsBefore)),
    "⟨"  => new(:title_st1, MtlPos.flags(Boundary, CapAfter)),
    "<"  => new(:title_st2, MtlPos.flags(Boundary, CapAfter)),
    "‹"  => new(:title_st3, MtlPos.flags(Boundary, CapAfter)),
    "⟩"  => new(:title_cl1, MtlPos.flags(Boundary, NoWsBefore)),
    ">"  => new(:title_cl2, MtlPos.flags(Boundary, NoWsBefore)),
    "›"  => new(:title_cl3, MtlPos.flags(Boundary, NoWsBefore)),
    "["  => new(:brack_st1, MtlPos.flags(Boundary, CapAfter)),
    "{"  => new(:brack_st2, MtlPos.flags(Boundary, CapAfter)),
    "]"  => new(:brack_cl1, MtlPos.flags(Boundary, NoWsBefore)),
    "}"  => new(:brack_cl2, MtlPos.flags(Boundary, NoWsBefore)),
    "("  => new(:paren_st1, MtlPos.flags(Boundary)),
    ")"  => new(:paren_cl1, MtlPos.flags(Boundary, NoWsBefore)),
    "\"" => new(:db_quote, MtlPos.flags(Boundary, NoWsBefore)),
    "'"  => new(:sg_quote, MtlPos.flags(Boundary, NoWsBefore)),
    " "  => new(:space, MtlPos.flags(NoWsBefore)),
    ","  => new(:comma, MtlPos.flags(NoWsBefore)),
    "､"  => new(:cenum, MtlPos.flags(NoWsBefore, JoinWord)),
    ":"  => new(:colon, MtlPos.flags(Boundary, CapAfter, NoWsBefore)),
    ";"  => new(:smcln, MtlPos.flags(Boundary)),
    "·"  => new(:middot, MtlPos.flags(JoinWord)),
    "@"  => new(:atsign, MtlPos.flags(NoWsAfter)),
    "~"  => new(:tilde, MtlPos.flags(Boundary)),
    "–"  => new(:dash1, MtlPos.flags(Boundary)),
    "—"  => new(:dash2, MtlPos.flags(Boundary)),
    "…"  => new(:ellip1, MtlPos.flags(NoWsBefore)),
    "……" => new(:ellip2, MtlPos.flags(NoWsBefore)),
  }

  def self.map_punct(str : String)
    PUNCT_MAP[str] ||= new(:punct, :boundary)
  end
end
