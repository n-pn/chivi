require "./fold_left/*"

module MT::MTL
  extend self

  def fold_left!(curr : MtNode, left : MtNode) : MtNode
    case curr
    # when Nominal   then fold_noun_left!(curr, left)
    when Adverbial then fold_advb_left!(curr, left)
    when Adjective then fold_adjt_left!(curr, left)
    when Verbal    then fold_verb_left!(curr, left)
    else                curr
    end
  end

  def fold_left!(curr : MtNode, left : Nil) : MtNode
    curr
  end
end
