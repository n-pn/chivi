module CV::Capitalization
  extend self

  def cap_mode(char : Char, prev_mode : Int32 = 0) : Int32
    if prev_mode == 2
      return char == '⟩' ? 0 : 2
    end

    case char
    when ',', '}', ']'
      0
    when '“', '‘', '[', '{',
         ':', '!', '?', '.',
         '·'
      1
    when '⟨'
      2
    else
      prev_mode
    end
  end
end
