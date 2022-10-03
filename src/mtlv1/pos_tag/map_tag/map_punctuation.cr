struct CV::PosTag
  def self.map_punctuation(str : String)
    case str
    when "."           then new(:period, MtlPos.flags(Final, Break, CapAfter, NoWspace))
    when "!"           then new(:exclam, MtlPos.flags(Final, Break, CapAfter, NoWspace))
    when "?"           then new(:questm, MtlPos.flags(Final, Break, CapAfter, NoWspace))
    when "“"           then new(:quote_st1, MtlPos.flags(Start, Break))
    when "‘"           then new(:quote_st2, MtlPos.flags(Start, Break))
    when "”", "’"      then new(:quotecl, MtlPos.flags(Close, Break, NoWspace))
    when "⟨", "<", "‹" then new(:titlest, MtlPos.flags(Start, CapAfter))
    when "⟩", ">", "›" then new(:titlecl, MtlPos.flags(Close, NoWspace))
    when "[", "{"      then new(:brackst, MtlPos.flags(Start, CapAfter))
    when "]", "}"      then new(:brackcl, MtlPos.flags(Close, NoWspace))
    when "("           then new(:parenst, MtlPos.flags(Start))
    when ")"           then new(:parencl, MtlPos.flags(Close, NoWspace))
    when "\""          then new(:dbquote, MtlPos.flags(Start, Close, NoWspace))
    when " "           then new(:wspace, MtlPos.flags(NoWspace))
    when ","           then new(:comma, MtlPos.flags(NoWspace))
    when "､"           then new(:cenum, MtlPos.flags(NoWspace))
    when ":"           then new(:colon, MtlPos.flags(Break, CapAfter, NoWspace))
    when ";"           then new(:smcln, MtlPos.flags(Break))
    when "·"           then new(:middot)
    when "@"           then new(:atsign)
    when "~"           then new(:tilde, MtlPos.flags(Break))
    when "–", "—"      then new(:dashes, MtlPos.flags(Break))
    when "…", "……"     then new(:ellip, MtlPos.flags(NoWspace))
    else                    None
    end
  end
end
