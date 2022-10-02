require "../mtl_tag"

struct CV::PosTag
  class_getter adverb_map = load_map("src/cvmtl/mapping/adverbs.tsv")
  class_getter conjunt_map = load_map("src/cvmtl/mapping/conjunts.tsv")

  def map_adverb(key : String)
    @@adverb_map[key] || new(:adv_term)
    new(tag)
  end

  def map_conjt(key : String)
    @@conjunt_map[key] || new(:conjunct)
  end
end
