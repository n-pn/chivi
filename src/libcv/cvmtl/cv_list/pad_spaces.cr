require "../cv_node"

module CV::PadSpaces
  extend self

  def space?(left : CvNode, right : CvNode)
    return false if left.val.blank? || right.val.blank?

    left_char = left.val[-1]?

    case right.val[0]?
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ';', '!',
         '%', '~', '?'
      return left_char == ':'
    when '…'
      return left_char == ':' || left_char == '.'
    when ':'
      return false
    when '-', '—'
      return left.dic > 1
    when '·'
      return true
    end

    case left_char
    when '“', '‘', '⟨', '(', '[', '{'
      false
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ';', '!', '?', ':',
         '…', '·'
      true
    when '~', '-', '—'
      right.dic > 1
    else
      left.dic > 0 || right.dic > 0
    end
  end
end
