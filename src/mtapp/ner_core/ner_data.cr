require "./ner_node"

struct MT::NerData
  getter ener = {} of EntMark => NerNode
  getter sner = {} of EntMark => NerNode

  @[AlwaysInline]
  def add_ener(mark : EntMark, node : NerNode)
    return if @ener[mark]?.try(&.sum.> node.sum)
    @ener[mark] = node
  end

  @[AlwaysInline]
  def add_sner(mark : EntMark, node : NerNode)
    return if @sner[mark]?.try(&.sum.> node.sum)
    @sner[mark] = node
  end
end
