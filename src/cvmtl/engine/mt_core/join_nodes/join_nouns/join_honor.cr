module MT::Core
  def join_honor!(noun : BaseNode, prev : BaseNode)
    case prev
    when .time_words?, .nform?, .locat?, .posit?
      tag, pos = MapTag::Nform
    else
      tag, pos = MapTag::CapHuman
    end

    BasePair.new(prev, noun, tag, pos)
  end
end
