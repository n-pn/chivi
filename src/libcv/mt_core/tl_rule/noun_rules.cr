module CV::TlRule
  def meld_noun!(node : MtNode) : MtNode
    return unless succ = node.succ?

    case succ.tag
    when .ptitle?
      node.tag = node.tag.linage? ? PosTag::Snwtit : PosTag::Person
      node.fuse_right!(succ)
    else
      node
    end
  end
end
