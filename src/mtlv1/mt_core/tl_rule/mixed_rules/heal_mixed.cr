# module CV::TlRule

#   # ameba:disable Metrics/CyclomaticComplexity
#   def heal_veno!(node : MtTerm, prev : BaseNode?, succ : BaseNode?) : MtTerm
#     # puts [node, prev, succ]

#     case succ
#     when .nil?, .boundary?
#       # to fixed by prev?
#     when .aspect?, .vcompl?
#       return node.as_verb!(nil)
#     when .v_shi?, .v_you?
#       return node.as_noun!
#     when .nquants?
#       return node.as_verb!(nil) unless succ.nqtime?
#     when .pronouns?, .verbal?, .pre_zai?, .numbers?
#       return node.as_verb!(nil)
#       # when .nominal?
#       #   node = node.as_verb!(nil)
#       #   return node unless node.vintr? || node.vobj?
#       #   node.as_noun!
#     end

#     case prev
#     when .nil?, .boundary?
#       return (succ && succ.nominal?) ? node.as_verb!(nil) : node
#     when .pro_dems?, .qtnoun?, .verbal?
#       case succ
#       when .nil?, .boundary?, .particles?
#         return node.as_noun!
#       when .nominal?
#         return succ.succ?(&.pt_dep?) ? node.as_verb!(nil) : node.as_noun!
#       when .pt_dep?
#         return node.as_noun!
#       end
#     when .pre_zai?, .pre_bei?, .vauxil?, .advbial?, .pt_dev?, .pt_der?, .object?
#       return node.as_verb!(nil)
#     when .adjts?
#       return node.as_verb!(nil) unless prev.is_a?(MtTerm)
#       return prev.modis? ? node.as_noun! : node.as_verb!(nil)
#     when .pt_dep?
#       # TODO: check for adjt + ude1 + verb (grammar error)
#       return prev.prev?(&.advbial?) ? node.as_verb!(nil) : node.as_noun!
#     when .nhanzis?
#       return prev.key == "一" ? node.as_verb!(nil) : node.as_noun!
#     when .preposes?
#       return succ.try(&.nominal?) ? node.as_verb!(nil) : node.as_noun!
#     end

#     node
#   end

#   # ameba:disable Metrics/CyclomaticComplexity
#   def heal_ajno!(node : MtTerm, prev : BaseNode?, succ : BaseNode?) : BaseNode
#     # puts [node, prev, succ, "heal_ajno"]

#     case succ
#     when .nil?, .boundary?
#       return node if !prev || prev.boundary?
#       case prev
#       when .nil?, .boundary? then return node
#       when .modis?, .pro_dems?, .quantis?, .nqnoun?
#         return node.as_noun!
#       when .object?, .pt_der?, .adjts?, .advbial?
#         return node.as_adjt!(nil)
#       when .conjunct?
#         return prev.prev?(&.nominal?) ? node.as_adjt!(nil) : node
#       else
#         return node.as_noun!
#       end
#     when .vdir?
#       return node.as_verb!(nil)
#     when .v_xia?, .v_shang?
#       return node.as_noun!
#     when .pt_dep?, .pt_dev?, .pt_der?, .mopart?
#       return node.as_adjt!(nil)
#     when .verbal?, .preposes?
#       return node.key.size > 2 ? node.as_noun! : node.as_adjt!(nil)
#     when .nominal?
#       return node.as_adjt!(nil)
#     else
#       if succ.is_a?(MtTerm) && succ.key == "到"
#         return node.as_adjt!(nil)
#       end
#     end

#     case prev
#     when .nil?, .boundary?, .advbial?
#       node.as_adjt!(nil)
#     when .modis?
#       node.as_noun!
#     else
#       node.as_adjt!(nil)
#     end
#   end
# end
