# module CV::TlRule
#   # ameba:disable Metrics/CyclomaticComplexity
#   def fold_pro_dems!(node : BaseNode, succ : BaseNode) : BaseNode
#     return node if node.key == "这儿" || node.key == "那儿"
#     return heal_pro_dem!(node) if succ.key.in?({"就"})

#     if succ.pro_ji? && (tail = succ.succ?)
#       if tail.nhanzis?
#         succ = fold_proji_nhanzi!(succ, tail)
#         return fold_prodem_nominal!(node, succ)
#       elsif node.pro_zhe? || node.pro_na1? || node.pro_na2?

#         if tag
#           succ = fold!(succ, tail, tag, dic: 6)
#           return scan_noun!(succ.succ?, prodem: node, nquant: succ) || node
#         else
#           return scan_noun!(succ, prodem: node, nquant: nil) || node
#         end
#       end
#     elsif node.pro_ji? && succ.nhanzis?
#       return fold_proji_nhanzi!(node, succ)
#     end

#     node, quanti, succ = split_prodem!(node)

#     if succ && !(succ.pro_dems? || succ.v_shi? || succ.v_you?)
#       return scan_noun!(succ, prodem: node, nquant: quanti).not_nil!
#     end

#     return heal_pro_dem!(node) unless quanti
#     fold_prodem_nominal!(node, quanti)
#   end

#   def fold_proji_nhanzi!(node : BaseNode, succ : BaseNode)
#     succ.val = succ.val.sub("mười", "chục")
#     node = fold!(node, succ, succ.tag, dic: 4)
#     fold_proji_right!(node)
#   end

#   def fold_proji_right!(node : BaseNode)
#     return node unless (tail = node.succ?) && tail.quantis?

#     node = fold!(node, tail, tag: tail.tag.qt_to_nq!, dic: 6)
#     scan_noun!(node.succ?, prodem: nil, nquant: node) || node
#   end

#   # def split_prodem!(node : BaseNode, succ : BaseNode? = node.succ?)
#   #   if succ && succ.quantis?
#   #     return {node, succ, succ.succ?}
#   #   end

#   #   return {node, nil, succ} unless node.can_split?

#   #   _, node.key, qt_key = match
#   #   node.tag, pro_val = map_pro_dem!(node.key)
#   #   return {node, nil, succ} if pro_val.empty?

#   #   qt_val = node.val.sub(" " + pro_val, "")
#   #   node.val = pro_val

#   #   qtnoun = MtTerm.new(qt_key, qt_val, PosTag::Qtnoun, 1, node.idx + 1)
#   #   qtnoun.fix_succ!(succ)
#   #   node.fix_succ!(qtnoun)

#   #   {node, qtnoun, succ}
#   # end

#   # def map_pro_dem!(key : String) : {PosTag, String}
#   #   case key
#   #   when "这" then {PosTag::ProZhe, "này"}
#   #   when "那" then {PosTag::ProNa1, "kia"}
#   #   when "几" then {PosTag::ProJi, "mấy"}
#   #   else          {PosTag::ProDem, ""}
#   #   end
#   # end
# end
