# module MT::TlRule
#   # ameba:disable Metrics/CyclomaticComplexity
#   def fold_noun_verb!(noun : MtNode, verb : MtNode)
#     return noun if noun.prev? { |x| x.pro_pers? || x.preposes? && !x.pre_bi3? }

#     verb = verb.modal_verbs? ? fold_vmodal!(verb) : fold_verbs!(verb)
#     return noun unless (succ = verb.succ?) && succ.pt_dep?

#     # && (verb.verb? || verb.modal_verbs?)
#     return noun unless tail = scan_noun!(succ.succ?)
#     case tail.key
#     when "时候"
#       noun = fold!(noun, succ.set!(""), MapTag::DcPhrase)
#       return fold!(noun, tail.set!("lúc"), MapTag::Texpr, flip: true)
#     end

#     # if verb.verb_no_obj? && (verb_2 = tail.succ?) && verb_2.maybe_verb?
#     #   verb_2 = verb_2.advb_words? ? fold_adverbs!(verb_2) : fold_verbs!(verb_2)

#     #   if !verb_2.verb_no_obj? && verb.prev?(&.object?)
#     #     tail = fold!(tail, verb_2, MapTag::SubjVerb)
#     #     noun = fold!(noun, verb, MapTag::SubjVerb)
#     #     return fold!(noun, succ.set!(""), flip: true)
#     #   end
#     # end

#     left = fold!(noun, verb, MapTag::Vform)

#     defn = fold!(left, succ.set!(""), MapTag::DcPhrase, flip: true)
#     tag = tail.proper_nouns? || tail.cap_human? ? tail.tag : MapTag::Nform

#     fold!(defn, tail, tag, flip: true)
#   end
# end
