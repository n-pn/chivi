module CV::TlRule
  def fold_nhanzi!(node : MtNode) : MtNode
    return node unless (succ = node.succ?) && (succ_2 = succ.succ?)
    return node unless succ_2.nhanzi? && succ.key == "点"
    return node if succ_2.succ?(&.key.== "分")

    node.key = "#{node.key}#{succ.key}#{succ_2.key}"
    node.val = "#{node.val} chấm #{succ_2.val}"

    # TODO: correcting number unit system
    node.fix_succ!(succ_2)
  end
end
