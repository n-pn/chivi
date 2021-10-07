module CV::TlRule
  extend self

  def end_sentence?(node : Nil)
    true
  end

  def end_sentence?(node : MtNode)
    node.endsts?
  end
end
