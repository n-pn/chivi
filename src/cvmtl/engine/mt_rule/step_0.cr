require "./_step_0/**"

module MT::Core::Step0
  extend self

  def run!(head : MtNode, tail : MtNode) : Nil
    while (head = head.succ?) && head.is_a?(MonoNode)
      case head
      when .numbers?      then head = fuse_number!(head)
      when .adjt_words?   then head = fuse_adjt!(head)
      when .verbal_words? then head = fuse_verb!(head)
      end
    end
  end
end
