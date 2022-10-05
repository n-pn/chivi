module CV::TlRule
  def fold_ndigit!(node : MtNode, prev : MtNode? = nil)
    return node unless (succ = node.succ?) && succ.is_a?(MtTerm)
    return fold_ndigit_nhanzi!(node, succ) if succ.nhanzis?

    return node unless prev && (succ.key == "点" || succ.key == "时")
    fold_number_hour!(node, succ)
  end

  def fold_ndigit_nhanzi!(node : MtNode, succ : MtNode) : MtNode
    key_io = String::Builder.new(node.key)
    val_io = String::Builder.new(node.val)

    match_tag = PosTag.new(:nhanzi0)

    while succ.tag == match_tag
      key_io << succ.key
      val_io << " " << succ.val
      break unless (succ = succ.succ?) && succ.is_a?(MtTerm)
      match_tag = PosTag::Ndigit1
    end

    node.key = key_io.to_s
    node.val = val_io.to_s # TODO: correct unit system

    node.tag = PosTag::Numeric
    node.tap(&.fix_succ!(succ))
  end
end
