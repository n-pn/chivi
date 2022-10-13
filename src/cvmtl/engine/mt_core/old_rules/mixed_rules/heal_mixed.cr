# module MT::TlRule

#   # ameba:disable Metrics/CyclomaticComplexity
#   def heal_veno!(node : MonoNode, prev : BaseNode?, succ : BaseNode?) : MonoNode
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
#     when .pronouns?, .verb_words?, .pre_zai?, .numbers?
#       return node.as_verb!(nil)
#       # when .noun_words?
#       #   node = node.as_verb!(nil)
#       #   return node unless node.vintr? || node.vobj?
#       #   node.as_noun!
#     end

#     case prev
#     when .nil?, .boundary?
#       return (succ && succ.noun_words?) ? node.as_verb!(nil) : node
#     when .pro_dems?, .qtnoun?, .verb_words?
#       case succ
#       when .nil?, .boundary?, .particles?
#         return node.as_noun!
#       when .noun_words?
#         return succ.succ?(&.pt_dep?) ? node.as_verb!(nil) : node.as_noun!
#       when .pt_dep?
#         return node.as_noun!
#       end
#     when .pre_zai?, .pre_bei?, .vauxil?, .advb_words?, .pt_dev?, .pt_der?, .object?
#       return node.as_verb!(nil)
#     when .adjt_words?
#       return node.as_verb!(nil) unless prev.is_a?(MonoNode)
#       return prev.amod_words? ? node.as_noun! : node.as_verb!(nil)
#     when .pt_dep?
#       # TODO: check for adjt + ude1 + verb (grammar error)
#       return prev.prev?(&.advb_words?) ? node.as_verb!(nil) : node.as_noun!
#     when .nhanzis?
#       return prev.key == "一" ? node.as_verb!(nil) : node.as_noun!
#     when .preposes?
#       return succ.try(&.noun_words?) ? node.as_verb!(nil) : node.as_noun!
#     end

#     node
#   end

#   # ameba:disable Metrics/CyclomaticComplexity
#   def heal_ajno!(node : MonoNode, prev : BaseNode?, succ : BaseNode?) : BaseNode
#     # puts [node, prev, succ, "heal_ajno"]

#     case succ
#     when .nil?, .boundary?
#       return node if !prev || prev.boundary?
#       case prev
#       when .nil?, .boundary? then return node
#       when .amod_words?, .pro_dems?, .quantis?, .nqnoun?
#         return node.as_noun!
#       when .object?, .pt_der?, .adjt_words?, .advb_words?
#         return node.as_adjt!(nil)
#       when .conjunct?
#         return prev.prev?(&.noun_words?) ? node.as_adjt!(nil) : node
#       else
#         return node.as_noun!
#       end
#     when .vdir?
#       return node.as_verb!(nil)
#     when .v_xia?, .v_shang?
#       return node.as_noun!
#     when .pt_dep?, .pt_dev?, .pt_der?, .mopart?
#       return node.as_adjt!(nil)
#     when .verb_words?, .preposes?
#       return node.key.size > 2 ? node.as_noun! : node.as_adjt!(nil)
#     when .noun_words?
#       return node.as_adjt!(nil)
#     else
#       if succ.is_a?(MonoNode) && succ.key == "到"
#         return node.as_adjt!(nil)
#       end
#     end

#     case prev
#     when .nil?, .boundary?, .advb_words?
#       node.as_adjt!(nil)
#     when .amod_words?
#       node.as_noun!
#     else
#       node.as_adjt!(nil)
#     end
#   end
# end
