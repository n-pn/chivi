module CV::TlRule
  def fold_adjt_noun!(adjt : MtNode, noun : MtNode?, ude1 : MtNode? = nil)
    return adjt if !noun
    flip = true

    if ude1
      adjt = fold!(adjt, ude1.set!(""), PosTag::DefnPhrase, 2)
      return adjt unless (noun = scan_noun!(noun, mode: 2))
    else
      case adjt.tag
      when .aform?    then return adjt
      when .adjt?     then return adjt if adjt.key.size > 1
      when .modifier? then flip = !do_not_flip?(adjt.key)
      end
      noun = fold_nouns!(noun, mode: 1)
    end

    return adjt unless noun.nouns?

    noun = fold!(adjt, noun, noun.tag, dic: 6, flip: flip)
    fold_noun_after!(noun)
  end

  def do_not_flip?(key : String)
    {"原"}.includes?(key)
  end
end
