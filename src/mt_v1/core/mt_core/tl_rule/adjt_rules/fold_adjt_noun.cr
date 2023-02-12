module M1::TlRule
  def fold_adjt_noun!(adjt : MtNode, noun : MtNode?, ude1 : MtNode? = nil)
    # puts [adjt, noun, ude1, "fold_adjt_noun"]

    return adjt unless noun
    flip = true

    if ude1 && (fold = fold_ude1!(ude1: ude1, prev: adjt, succ: noun))
      return ude1 == fold ? adjt : fold
    end

    case adjt.tag
    when .aform? then return adjt
    when .adjt?  then return adjt if adjt.key.size > 2
    when .modi?  then flip = adjt.key != "原"
    end

    noun = fold_nouns!(noun, mode: 0)
    return adjt unless noun.nominal?

    # puts [noun, noun.prev?, noun.succ?, adjt.succ?]

    noun = fold!(adjt, noun, noun.tag, dic: 6, flip: flip)
    fold_noun_after!(noun)
  end

  def do_not_flip?(key : String)
  end
end
