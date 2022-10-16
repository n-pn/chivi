module MT::PosTag
  PUNCT_MAP = {
    "." => make(:period, MtlPos.flags(Boundary, CapAfter, NoSpaceL)),
    "!" => make(:exclpm, MtlPos.flags(Boundary, CapAfter, NoSpaceL)),
    "?" => make(:quespm, MtlPos.flags(Boundary, CapAfter, NoSpaceL)),

    "“" => make(:quote_st1, MtlPos.flags(Boundary, NoSpaceR)),
    "‘" => make(:quote_st2, MtlPos.flags(Boundary, NoSpaceR)),
    "”" => make(:quote_cl1, MtlPos.flags(Boundary, NoSpaceL)),
    "’" => make(:quote_cl2, MtlPos.flags(Boundary, NoSpaceL)),

    "⟨" => make(:title_st1, MtlPos.flags(Boundary, NoSpaceR, CapAfter)),
    "<" => make(:title_st2, MtlPos.flags(Boundary, NoSpaceR, CapAfter)),
    "‹" => make(:title_st3, MtlPos.flags(Boundary, NoSpaceR, CapAfter)),
    "⟩" => make(:title_cl1, MtlPos.flags(Boundary, NoSpaceL)),
    ">" => make(:title_cl2, MtlPos.flags(Boundary, NoSpaceL)),
    "›" => make(:title_cl3, MtlPos.flags(Boundary, NoSpaceL)),

    "[" => make(:brack_st1, MtlPos.flags(Boundary, NoSpaceR, CapAfter)),
    "{" => make(:brack_st2, MtlPos.flags(Boundary, NoSpaceR, CapAfter)),
    "]" => make(:brack_cl1, MtlPos.flags(Boundary, NoSpaceL)),
    "}" => make(:brack_cl2, MtlPos.flags(Boundary, NoSpaceL)),

    "(" => make(:paren_st1, MtlPos.flags(Boundary, NoSpaceR)),
    ")" => make(:paren_cl1, MtlPos.flags(Boundary, NoSpaceL)),

    "\"" => make(:db_quote, MtlPos.flags(Boundary, NoSpaceL)),
    "'"  => make(:sg_quote, MtlPos.flags(Boundary, NoSpaceL)),

    "," => make(:comma, MtlPos.flags(NoSpaceL)),
    "､" => make(:cenum, MtlPos.flags(NoSpaceL, BondWord)),

    ":" => make(:colon, MtlPos.flags(NoSpaceL, Boundary, CapAfter)),
    ";" => make(:smcln, MtlPos.flags(NoSpaceL, Boundary)),

    " " => make(:space, MtlPos.flags(NoSpaceL, NoSpaceR)),
    "·" => make(:middot, MtlPos.flags(NoSpaceL, NoSpaceR, BondWord)),

    "+" => make(:pl_mark, MtlPos.flags(NoSpaceL, NoSpaceR)),
    "-" => make(:mn_mark, MtlPos.flags(NoSpaceL, NoSpaceR)),

    "@" => make(:atsign, MtlPos.flags(NoSpaceR)),
    "~" => make(:tilde, MtlPos.flags(NoSpaceL, Boundary)),

    "–" => make(:dash1, MtlPos.flags(NoSpaceL, Boundary)),
    "—" => make(:dash2, MtlPos.flags(Boundary)),

    "…"  => make(:ellip1, MtlPos.flags(NoSpaceL)),
    "……" => make(:ellip2, MtlPos.flags(NoSpaceL)),
  }

  def self.map_punct(str : String)
    PUNCT_MAP[str] ||= make(:punct, :boundary)
  end
end
