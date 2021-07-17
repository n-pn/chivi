module CV::Improving
  def fix_string!(node : MtNode) : MtNode
    if node.key =~ /^\d+$/
      node.update!(tag: PosTag::Number)
      return fix_number!(node)
    end

    # TODO: handle http
    node
  end
end
