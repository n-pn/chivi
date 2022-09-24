module CV::MTL
  extend self

  def ner_recog(input : Array(Char), index = 0, mode = 1_i8)
    char = input.unsafe_fetch(index)

    case
    when letter = map_letter(char)
      recog_string(input, char, letter, index &+ 1)
    when number = map_number(char)
      recog_number(input, char, number, index &+ 1)
    else
      nil
    end
  end

  def recog_string(input : Array(Char),
                   key : Char,
                   val : Char,
                   index : Int32 = 1)
    key_io = String::Builder.new
    key_io << key

    val_io = String::Builder.new
    val_io << val

    while index < input.size
      char = input.unsafe_fetch(index)
      index += 1

      case
      when letter = map_letter(char)
        key_io << char
        val_io << letter
      when number = map_number(char)
        key_io << char
        val_io << number
      when char == '_'
        key_io << char
        val_io << char
      when ':'
        break unless input[index]? == '/' && input[index + 1]? == '/'
        break unless val_io.to_s =~ /^https?/

        key_io << input[index] << input[index + 1]
        val_io << "//"
        return recog_anchor(input, key_io, val_io, index + 2)
      else
        break
      end
    end

    MtTerm.new(key_io.to_s, val_io.to_s, PosTag::Nother, 0)
  end

  def recog_anchor(input : Array(Char), key_io, val_io, index)
    while index < input.size
      char = input.unsafe_fetch(index)
      index += 1

      case
      when letter = map_letter(char)
        key_io << char
        val_io << letter
      when number = map_number(char)
        key_io << char
        val_io << number
      when in_uri?(char)
        key_io << char
        val_io << char
      else
        break
      end
    end

    MtTerm.new(key_io.to_s, val_io.to_s, PosTag::Urlstr, 0)
  end

  def recog_number(input : Array(Char), key : Char, val : Char, index = 1)
    key_io = String::Builder.new
    key_io << key

    val_io = String::Builder.new
    val_io << val

    while index < input.size
      char = input.unsafe_fetch(index)
      index += 1

      case
      when number = map_number(char)
        key_io << char
        val_io << number
      when char == '_'
        key_io << char
        val_io << char
      else
        break
      end
    end

    MtTerm.new(key_io.to_s, val_io.to_s, PosTag::Number, 0)
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

  def in_uri?(char : Char)
    {':', '/', '.', '?', '@', '=', '%', '+', '-', '~', '_'}.includes?(char)
  end
end
