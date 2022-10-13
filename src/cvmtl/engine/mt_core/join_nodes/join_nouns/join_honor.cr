module MT::Core
  def join_honor!(noun : MtNode, prev : MtNode)
    case prev
    when .time_words?, .nform?, .locat?, .posit?
      tag, pos = PosTag::Nform
    else
      tag, pos = PosTag::CapHuman
    end

    PairNode.new(prev, noun, tag, pos)
  end
end
