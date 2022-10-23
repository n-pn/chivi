# module MT::TlRule
#   def fold_prodem_nominal!(prodem : MtNode?, nominal : MtNode?)
#     return nominal unless prodem

#     if nominal
#       if nominal.vobj?
#         prodem = heal_pro_dem!(prodem)
#         return fold!(prodem, nominal, PosTag::SubjVerb)
#       end

#       # puts [prodem.prev?, prodem.succ?]
#       # puts [nominal.prev?, nominal.succ?]

#       flip = nominal.noun_words? && should_flip_prodem?(prodem)
#       tag = !prodem.pro_dem? && nominal.qtnoun? ? PosTag::ProDem : nominal.tag
#       return fold!(prodem, nominal, tag, flip: flip)
#     end

#     heal_pro_dem!(prodem)
#   end

#   def should_flip_prodem?(prodem : MtNode)
#     return false if prodem.pro_ji?
#     return true unless prodem.pro_dem? # pro_ji, pro_na1, pro_na2
#     {"另", "其他", "此", "某个", "某些"}.includes?(prodem.key)
#   end

#   # ameba:disable Metrics/CyclomaticComplexity
#   def heal_pro_dem!(pro_dem : MtNode) : MtNode
#     case pro_dem
#     when .pro_zhe?
#       case succ = pro_dem.succ?
#       when .nil?, .preposes?, BaseList
#         pro_dem.set!("cái này")
#       when .verb_words?
#         pro_dem.set!("đây")
#       when .comma?
#         if (succ_2 = succ.succ?) && succ_2.pro_zhe? # && succ_2.succ?(&.maybe_verb?)
#           pro_dem.set!("đây")
#         else
#           pro_dem.set!("cái này")
#         end
#       when .boundary?
#         pro_dem.set!("cái này")
#       else
#         if pro_dem.prev?(&.noun_words?)
#           pro_dem.set!("giờ")
#         else
#           pro_dem.set!("cái này")
#         end
#       end
#     when .pro_na1?
#       has_verb_after?(pro_dem) ? pro_dem : pro_dem.set!("vậy")
#     else pro_dem
#     end
#   end
# end
