module CV::TlRule
  def scan_adjt!(node : MtNode?) : MtNode?
    case node
    when .nil? then nil
    when .verbs?
      node = fold_verbs!(node)

      node.each do |body|
        return node.set!(PosTag::Aform) if body.key.includes?("得")
      end

      node
    when .adverbs?  then fold_adverbs!(node)
    when .modifier? then fold_modifier!(node)
    when .ajno?     then fold_adjts!(cast_adjt!(node))
    when .adjts?    then fold_adjts!(node)
    when .nouns?    then fold_nouns!(node)
    else                 node
    end
  end
end
