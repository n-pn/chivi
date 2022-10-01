struct CV::PosTag
  CapHuman = new(:cap_human, MtlPos.flags(Proper, People, Ktetic))
  CapAffil = new(:cap_affil, MtlPos.flags(Proper, Locale, Ktetic))

  def self.object_id(tag : String, key = "")
    case tag[1]?
    when 'r' then CapHuman
    when 'a' then CapAffil
    when 'l' then new(:cap_brand, MtlPos.flags(Proper))
    when 'w' then new(:cap_title, MtlPos.flags(Proper, Ktetic))
    else          new(:cap_other, MtlPos.flags(Proper, Ktetic))
    end
  end

  def self.parse_noun(tag : String, key = "")
    case tag[1]?
    when 'a' then Nattr
    when 't' then Ntime
    when 's' then Posit
    when 'f' then Locat
    when 'h' then Honor
      # when 'o' then Nobjt
    else Noun
    end
  end
end
