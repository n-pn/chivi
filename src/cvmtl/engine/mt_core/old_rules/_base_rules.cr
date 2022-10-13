module MT::TlRule
  extend self

  def fold!(head : BaseNode, tail : BaseNode,
            tag : PosTag = MapTag::LitBlank, dic : Int32 = 9,
            flip : Bool = false)
    SeriNode.new(head, tail, tag, dic, idx: head.idx, flip: flip)
  end
end
