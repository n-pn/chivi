module CV::MTL
  extend self

  def scan_string(input : Array(Char), index : Int32 = 0)
    buffer = String::Builder.new
    buffer << input.unsafe_fetch(index)

    index &+= 1

    while index < input.size
      char = input.unsafe_fetch(index)
      index += 1

      case
      when letter = map_letter(char)
        buffer << letter
      when number = map_number(char)
        buffer << number
      when char == '_'
        buffer << char
      else
        break
      end
    end

    {buffer.to_s, index}
  end

  def map_letter(char : Char) : Char?
    return char if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
    return char - 65248 if (char >= 'ａ' && char <= 'ｚ') || (char >= 'Ａ' && char <= 'Ｚ')
    nil
  end

  def map_number(char : Char) : Char?
    return char if (char >= '0' && char <= '9')
    return char - 65248 if (char >= '０' && char <= '９')
    nil
  end
end
