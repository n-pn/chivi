require "./_generics/*"

# module MtlV2::AST
#   class BaseList < BaseNode
#     getter head : BaseNode
#     getter tail : BaseNode

#     def initialize(@head : BaseNode, @tail = head, @mark = 0)
#       self.set_prev(head.prev?)
#       self.set_succ(tail.succ?)
#     end

#     def add_head(node : BaseNode) : Nil
#       self.set_prev(node.prev?)
#       node.set_succ(@head)
#       @head = node

#       node.set_prev(nil)
#     end

#     def add_tail(node : BaseNode) : Nil
#       self.set_succ(node.succ?)
#       node.set_prev(@tail)
#       @tail = node

#       node.set_succ(nil)
#     end

#     def apply_cap!(cap : Bool = true)
#       node = @head

#       while node
#         cap = node.is_a?(PunctWord) ? node.flag.cap_after? : node.apply_cap!(cap)
#         node = node.succ?
#       end

#       cap
#     end

#     private def should_space?(left : PunctWord, right : PunctWord)
#       left.space_after? || right.space_before?
#     end

#     private def should_space?(left : PunctWord, right : BaseNode)
#       left.space_after?
#     end

#     private def should_space?(left : BaseNode, right : PunctWord)
#       right.space_before?
#     end

#     private def should_space?(left : BaseNode, right : BaseNode)
#       true
#     end

#     def to_txt(io : IO) : Nil
#       node = @head
#       node.to_txt(io)

#       while succ = node.succ?
#         io << ' ' if should_space?(node, succ)
#         succ.to_txt(io)
#         node = succ
#       end
#     end

#     def to_mtl(io : IO) : Nil
#       io << '〈' << @mark << '\t'

#       node = @head
#       node.to_mtl(io)

#       while succ = node.succ?
#         io << '\t' if should_space?(node, succ)
#         succ.to_mtl(io)
#         node = succ
#       end

#       io << '〉'
#     end

#     def inspect(io : IO, pad = -1) : Nil
#       return unless node = @head
#       node.inspect(io, pad &+ 1)

#       while succ = node.succ?
#         succ.inspect(io, pad &+ 1)
#         node = succ
#       end
#     end
#   end
# end
