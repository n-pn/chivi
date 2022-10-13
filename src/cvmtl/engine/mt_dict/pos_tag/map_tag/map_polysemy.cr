module MT::PosTag
  def self.map_polysemy(tag : String, key = "")
    case tag
    when "~vn" then make(:pl_veno, MtlPos.flags(MaybeVerb, MaybeNoun))
    when "~an" then make(:pl_ajno, MtlPos.flags(MaybeAdjt, MaybeNoun))
    when "~vd" then make(:pl_vead, MtlPos.flags(MaybeVerb, MaybeAdvb))
    when "~ad" then make(:pl_ajad, MtlPos.flags(MaybeAdjt, MaybeAdvb))
    when "~nd" then make(:pl_noad, MtlPos.flags(MaybeNoun, MaybeAdvb))
    else            make(:pl_word)
    end
  end
end
