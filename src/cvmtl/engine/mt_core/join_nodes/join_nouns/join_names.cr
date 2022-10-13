module MT::Core
  def join_name!(name : MtNode, prev : MtNode)
    case prev
    when .cap_affil?
      return PairNode.new(prev, name, flip: true)
    when .cap_human?
      return PairNode.new(prev, name, flip: false) if name.cap_human?
    end

    PairNode.new(prev, name, PosTag::Nform)
  end
end
