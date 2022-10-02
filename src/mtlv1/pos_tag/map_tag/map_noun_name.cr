struct CV::PosTag
  CapHuman = new(:cap_human, MtlPos.flags(Nounish, Proper, People, Ktetic))
  CapAffil = new(:cap_affil, MtlPos.flags(Nounish, Proper, Locale, Ktetic))
  CapBrand = new(:cap_brand, MtlPos.flags(Nounish, Proper))
  CapTitle = new(:cap_title, MtlPos.flags(Nounish, Proper, Ktetic))
  CapOther = new(:cap_other, MtlPos.flags(Nounish, Proper, Ktetic))

  def self.map_name(tag : String, key = "")
    case tag[1]?
    when 'r' then CapHuman
    when 'a' then CapAffil
    when 'l' then CapBrand
    when 'w' then CapTitle
    else          CapOther
    end
  end

  def self.map_noun(tag : String, key = "")
    case tag[1]?
    when 'a' then new(:nattr, :nounish)
    when 't' then new(:ntime, :nounish)
    when 's' then new(:posit, :nounish)
    when 'f' then new(:locat, :nounish)
    when 'h' then new(:honor, :nounish)
    when 'o' then Nobjt
    when 'l' then new(:nbase, :nounish)
    else          Nbase
    end
  end
end
