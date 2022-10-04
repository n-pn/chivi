struct CV::PosTag
  def self.map_polysemy(tag : String, key = "")
    case tag
    when "~vn" then new(:pl_veno, MtlPos.flags(Verbish, Nounish))
    when "~vd" then new(:pl_veno, MtlPos.flags(Verbish, Advbial))
    when "~an" then new(:pl_veno, MtlPos.flags(Adjtish, Nounish))
    when "~ad" then new(:pl_veno, MtlPos.flags(Adjtish, Advbial))
    when "~nd" then new(:pl_veno, MtlPos.flags(Advbial, Nounish))
    else            new(:uniqword)
    end
  end
end
