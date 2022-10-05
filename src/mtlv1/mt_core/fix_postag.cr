# module CV::MTL
#   extend self

#   def fix_postag(node : MtNode)
#     while node = node.prev?
#       case node
#       when .polysemy? then fix_polysemy(node)
#       else                 node
#       end
#     end
#   end

#   def fix_polysemy(node : MtNode)
#     prev = prev_node(node)
#     succ = succ_node(node)

#     case node.tag
#     when .pl_vead? then fix_vead(node, prev, succ)
#     when .pl_veno? then fix_veno(node, prev, succ)
#     when .pl_ajno? then fix_ajno(node, prev, succ)
#     when .pl_ajad? then fix_ajad(node, prev, succ)
#     else                node
#     end
#   end

#   def prev_node(node : MtNode)
#     return unless prev = node.prev?
#     prev.quoteop? ? prev.prev? : prev
#   end

#   def succ_node(node : MtNode)
#     return unless succ = node.succ?
#     succ.quotecl? ? succ.succ? : succ
#   end

#   def fix_vead(node, prev, succ)
#     case succ
#     when .nil?, .boundary?, .nominal?
#       MtDict.fix_verb!(node)
#     when .aspect?, .vcompl?
#       MtDict.fix_adverb!(node)
#     when .verbal?, .vmodals?, .preposes?, .adjts?
#       MtDict.fix_adverb!(node)
#     else
#       MtDict.fix_verb!(node)
#     end
#   end

#   def fix_ajad(node, prev, succ)
#     case succ
#     when .verbal?, .vmodals?, .preposes?, .adjts?
#       MtDict.fix_adverb!(node)
#     else
#       MtDict.fix_adjt!(node)
#     end
#   end

#   # ameba:disable Metrics/CyclomaticComplexity
#   def fix_veno(node, prev, succ) : MtTerm
#     # puts [node, prev, succ]

#     case succ
#     when .nil?, .boundary?
#       # to fixed by prev?

#     when .aspect?, .vcompl?
#       return MtDict.fix_verb!(node)
#     when .v_shi?, .v_you?
#       return MtDict.fix_noun!(node)
#     when .nquants?
#       return MtDict.fix_verb!(node) unless succ.nqtime?
#     when .pronouns?, .verbal?, .pre_zai?, .numbers?
#       return MtDict.fix_verb!(node)
#       # when .nominal?
#       #   node = MtDict.fix_verb!(node)
#       #   return node unless node.vintr? || node.vobj?
#       #   MtDict.fix_noun!(node)
#     end

#     case prev
#     when .nil?, .boundary?
#       return (succ && succ.nominal?) ? MtDict.fix_verb!(node) : node
#     when .pro_dems?, .qtnoun?, .verbal?
#       case succ
#       when .nil?, .boundary?, .particles?
#         return MtDict.fix_noun!(node)
#       when .nominal?
#         return succ.succ?(&.pt_dep?) ? MtDict.fix_verb!(node) : MtDict.fix_noun!(node)
#       when .pt_dep?
#         return MtDict.fix_noun!(node)
#       end
#     when .pre_zai?, .pre_bei?, .vauxil?,
#          .advbial?, .pt_dev?, .pt_der?, .object?
#       return MtDict.fix_verb!(node)
#     when .adjts?
#       return MtDict.fix_verb!(node) unless prev.is_a?(MtTerm)
#       return prev.modis? ? MtDict.fix_noun!(node) : MtDict.fix_verb!(node)
#     when .pt_dep?
#       # TODO: check for adjt + ude1 + verb (grammar error)
#       return prev.prev?(&.advbial?) ? MtDict.fix_verb!(node) : MtDict.fix_noun!(node)
#     when .nhanzis?
#       return prev.key == "一" ? MtDict.fix_verb!(node) : MtDict.fix_noun!(node)
#     when .preposes?
#       return succ.try(&.nominal?) ? MtDict.fix_verb!(node) : MtDict.fix_noun!(node)
#     end

#     node
#   end

#   # ameba:disable Metrics/CyclomaticComplexity
#   def heal_ajno!(node : MtNode, prev : MtNode?, succ : MtNode?) : MtNode
#     # puts [node, prev, succ, "heal_ajno"]

#     case succ
#     when .nil?, .boundary?
#       return node if !prev || prev.boundary?
#       case prev
#       when .nil?, .boundary? then return node
#       when .modis?, .pro_dems?, .quantis?, .nqnoun?
#         return MtDict.fix_noun!(node)
#       when .object?, .pt_der?, .adjts?, .advbial?
#         return MtDict.fix_adjt!(node)
#       when .conjunct?
#         return prev.prev?(&.nominal?) ? MtDict.fix_adjt!(node) : node
#       else
#         return MtDict.fix_noun!(node)
#       end
#     when .vdir?
#       return MtDict.fix_verb!(node)
#     when .v_xia?, .v_shang?
#       return MtDict.fix_noun!(node)
#     when .pt_dep?, .pt_dev?, .pt_der?, .mopart?
#       return MtDict.fix_adjt!(node)
#     when .verbal?, .preposes?
#       return node.key.size > 2 ? MtDict.fix_noun!(node) : MtDict.fix_adjt!(node)
#     when .nominal?, .position?
#       node = MtDict.fix_adjt!(node)
#       return node.set!(PosTag::Modi)
#     else
#       if succ.is_a?(MtTerm) && succ.key == "到"
#         return MtDict.fix_adjt!(node)
#       end
#     end

#     case prev
#     when .nil?, .boundary?, .advbial?
#       MtDict.fix_adjt!(node)
#     when .modis?
#       MtDict.fix_noun!(node)
#     else
#       node
#     end
#   end
# end
