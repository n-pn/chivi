struct CV::PosTag
  def self.map_polysemy(tag : String, key = "")
    case tag
    when "~vn" then new(:pl_veno, MtlPos.flags(MaybeVerb, MaybeNoun))
    when "~vd" then new(:pl_veno, MtlPos.flags(MaybeVerb, MaybeAdvb))
    when "~an" then new(:pl_veno, MtlPos.flags(MaybeAdjt, MaybeNoun))
    when "~ad" then new(:pl_veno, MtlPos.flags(MaybeAdjt, MaybeAdvb))
    when "~nd" then new(:pl_veno, MtlPos.flags(MaybeAdvb, MaybeNoun))
    else            new(:pl_word)
    end
  end
end
