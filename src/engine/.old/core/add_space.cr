module Chivi
  def add_space(input : Tokens)
    add_space = false

    input.each_with_object(Tokens.new) do |token, res|
      next if token.val == ""
      # if add_space && space_before?(token.val)
      # end

      if add_space && space_before?(token.val[0]?)
        res << Token.new("", " ", 0)
      end

      res << token
      add_space = token.dic > 0 || space_after?(token.val[-1]?)
    end
  end

  private def space_before?(char : Char?)
    return false if char.nil?

    case char
    when '”', '’', '⟩', ')', ']',
         '}', ',', '.', ':', ';',
         '!', '?', '%', ' ', '_',
         '…', '/', '\\', '~'
      false
    else
      true
    end
  end

  private def space_after?(char : Char?)
    # return true if char.nil?

    case char
    # when '”', '’', '⟩', ')', ']',
    #      '}', ',', '.', ':', ';',
    #      '!', '?', '…', '~'
    #   true
    # else
    # false
    when '“', '‘', '⟨', '(', '[', '{', ' ', '_', '/', '\\'
      false
    else
      true
    end
  end
end
