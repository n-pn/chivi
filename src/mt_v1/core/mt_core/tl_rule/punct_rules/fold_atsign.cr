# require "../../../../../mt_sp/sp_core"

# module M1::TlRule
#   def fold_atsign!(head : MtNode)
#     key_io = String::Builder.new

#     tail = head
#     while tail = tail.succ?
#       break if tail.key == " "
#       return head if tail.puncts?
#       key_io << tail.key
#     end

#     return head unless tail

#     key = key_io.to_s
#     return head if key.blank?

#     val = TextUtil.titleize(SP::MtCore.tl_sinovi(key, false))
#     key = "#{head.key}#{key}#{tail.key}"

#     if (prev = head.prev?) && prev.key == " "
#       head = prev
#       key = prev.key + key
#     end

#     tag = PosTag::Person

#     MtDefn.new(key, "@#{val}", tag, dic: 2, idx: head.idx).tap do |new_node|
#       new_node.fix_prev!(head.prev?)
#       new_node.fix_succ!(tail.succ?)
#     end
#   end
# end
