module MT::Core
  def join_name!(name : BaseNode, prev : BaseNode)
    case prev
    when .cap_affil?
      return BasePair.new(prev, name, flip: true)
    when .cap_human?
      return BasePair.new(prev, name, flip: false) if name.cap_human?
    end

    BasePair.new(prev, name, MapTag::Nform)
  end
end
