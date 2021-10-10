module CV::TlRule
  extend self

  def end_sentence?(node : Nil)
    true
  end

  def end_sentence?(node : MtNode)
    node.endsts?
  end

  def boundary?(node : Nil)
    true
  end

  def boundary?(node : MtNode)
    node == node.tag.none? || node.tag.puncts? || node.tag.interjection?
  end
end
