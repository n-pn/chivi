require "../cv_node"

module CV::PadSpaces
  extend self

  def space?(left : CvNode, right : CvNode)
    return false if left.val.blank? || right.val.blank?

    # handle .jpg case
    return false if right.dic == 1 && right.key =~ /^\.\w/

    prev_val = left.val[-1]?

    case right.val[0]?
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ';', '!',
         '%', '~', '?'
      return prev_val == ':'
    when '…'
      return prev_val == ':' || prev_val == '.'
    when ':'
      return false
    when '-', '—'
      return left.dic > 1
    when '·'
      return true
    end

    case prev_val
    when '“', '‘', '⟨', '(', '[', '{'
      return false
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ';', '!', '?', ':',
         '…', '·'
      return true
    when '~', '-', '—'
      right.dic > 1
    end

    left.dic > 0 || right.dic > 0
  end
end
