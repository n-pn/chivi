module MT::TlRule
  def fold_ndigit!(node : BaseNode, prev : BaseNode? = nil)
    return node unless (succ = node.succ?) && succ.is_a?(BaseTerm)
    return fold_ndigit_nhanzi!(node, succ) if succ.nhanzis?

    return node unless prev && (succ.key == "点" || succ.key == "时")
    fold_number_hour!(node, succ)
  end

  def fold_ndigit_nhanzi!(node : BaseNode, succ : BaseNode) : BaseNode
    key_io = String::Builder.new(node.key)
    val_io = String::Builder.new(node.val)

    match_tag = PosTag.new(:nhanzi0)

    while succ.tag == match_tag
      key_io << succ.key
      val_io << " " << succ.val
      break unless (succ = succ.succ?) && succ.is_a?(BaseTerm)
      match_tag = MapTag::Ndigit1
    end

    node.key = key_io.to_s
    node.val = val_io.to_s # TODO: correct unit system

    node.tag = MapTag::Numeric
    node.tap(&.fix_succ!(succ))
  end
end
