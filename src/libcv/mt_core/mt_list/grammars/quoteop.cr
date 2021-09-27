module CV::MTL::Grammars
  private def fix_quoteop!(node : MtNode)
    return node unless succ = node.succ
    return node unless succ_2 = succ.succ
    return node unless succ_2.tag.quotecl?
    succ.capitalize!
    succ.fuse_left!.fuse_right!
  end
end
