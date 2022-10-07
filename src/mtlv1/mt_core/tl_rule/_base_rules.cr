module CV::TlRule
  extend self

  def fold!(head : BaseNode, tail : BaseNode,
            tag : PosTag = PosTag::LitBlank, dic : Int32 = 9,
            flip : Bool = false)
    BaseSeri.new(head, tail, tag, dic, idx: head.idx, flip: flip)
  end
end
