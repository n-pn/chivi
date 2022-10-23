module MT::PosTag
  def self.map_polysemy(tag : String, key = "")
    case tag
    when "~vn" then make(:pl_veno, MtlPos.flags(Mixedpos, MaybeVerb, MaybeNoun))
    when "~an" then make(:pl_ajno, MtlPos.flags(Mixedpos, MaybeAdjt, MaybeNoun))
    when "~vd" then make(:pl_vead, MtlPos.flags(Mixedpos, MaybeVerb, MaybeAdvb))
    when "~ad" then make(:pl_ajad, MtlPos.flags(Mixedpos, MaybeAdjt, MaybeAdvb))
    when "~nd" then make(:pl_noad, MtlPos.flags(Mixedpos, MaybeNoun, MaybeAdvb))
    else            make(:pl_word, MtlPos.flags(Mixedpos))
    end
  end
end
