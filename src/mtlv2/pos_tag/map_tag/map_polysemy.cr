module MT::MapTag
  def self.map_polysemy(tag : String, key = "")
    case tag
    when "~vn" then make(:pl_veno, MtlPos.flags(MaybeVerb, MaybeNoun))
    when "~vd" then make(:pl_veno, MtlPos.flags(MaybeVerb, MaybeAdvb))
    when "~an" then make(:pl_veno, MtlPos.flags(MaybeAdjt, MaybeNoun))
    when "~ad" then make(:pl_veno, MtlPos.flags(MaybeAdjt, MaybeAdvb))
    when "~nd" then make(:pl_veno, MtlPos.flags(MaybeAdvb, MaybeNoun))
    else            make(:pl_word)
    end
  end
end
