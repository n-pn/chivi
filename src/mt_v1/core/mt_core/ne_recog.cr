module M1::MTL
  extend self

  def ner_recog(input : Array(Char), index = 0, mode = 1_i8)
    return unless char = input[index]?

    case
    when letter = map_letter(char)
      recog_string(input, char, letter, index &+ 1)
    when number = map_number(char)
      recog_number(input, char, number, index &+ 1)
    else
      nil
    end
  end

  def recog_string(input : Array(Char), key : Char | String, val : Char | String, start : Int32 = 1)
    key_io = String::Builder.new
    key_io << key

    val_io = String::Builder.new
    val_io << val

    index = start

    while index < input.size
      char = input[index]
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
        val = val_io.dup.to_s
        break unless val.starts_with?("http")

        val_io = String::Builder.new(val)
        key_io << input[index] << input[index + 1]
        val_io << "//"
        return recog_anchor(input, key_io, val_io, index + 2)
      else
        break
      end
    end

    key = key_io.to_s
    val = val_io.to_s

    MtDefn.new(key, val, PosTag::Nother, 0, idx: start)
  end

  def recog_anchor(input : Array(Char), key_io, val_io, index)
    while index < input.size
      char = input[index]
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

    MtDefn.new(key_io.to_s, val_io.to_s, PosTag::Urlstr, 0)
  end

  def recog_number(input : Array(Char), key : Char, val : Char, index = 1)
    # puts ["recog_number", input, index, key, val].colorize.yellow

    key_io = String::Builder.new
    key_io << key

    val_io = String::Builder.new
    val_io << val

    while index < input.size
      char = input[index]
      # puts [char, index, "current_char"]

      index += 1

      case
      when number = map_number(char)
        key_io << char
        val_io << number
      when char == '_'
        key_io << char
        val_io << char
      when letter = map_letter(char)
        key_io << char
        val_io << letter
        return recog_string(input, key_io.to_s, val_io.to_s, index)
      when char.in?(':', '：', '.', '．', '-', '－', '/', '／')
        break unless next_char = input[index]?
        break unless next_number = map_number(next_char)

        key_io << char << next_char

        if char > '！' # is full_width
          char_full = match_half_width(char)
          val_io << char_full << next_number

          char, char_full = char_full, char
        else
          char_full = match_full_width(char)
          val_io << char << next_number
        end

        return recog_number_2(input, key_io, val_io, char, char_full, index &+ 1)
      else
        break
      end
    end

    MtDefn.new(key_io.to_s, val_io.to_s, PosTag::Number, 0)
  end

  def match_half_width(char : Char)
    case char
    when '：' then ':'
    when '．' then '.'
    when '－' then '-'
    when '／' then '/'
    else          char
    end
  end

  def match_full_width(char : Char)
    case char
    when ':' then '：'
    when '.' then '．'
    when '-' then '－'
    when '/' then '／'
    else          char
    end
  end

  def recog_number_2(input : Array(Char), key_io, val_io, char_half : Char, char_full : Char,
                     index = 1)
    # puts ["recog_number_2", char_half, char_full, index].colorize.yellow
    count = 1 # number of `char` occurence

    while index < input.size
      char = input[index]
      index += 1

      if char == char_half || char == char_full
        break unless next_char = input[index]?
        break unless next_number = map_number(next_char)

        count += 1
        index += 1

        key_io << char << next_char
        val_io << char_half << next_number
      elsif number = map_number(char)
        key_io << char
        val_io << number
      else
        break
      end
    end

    MtDefn.new(key_io.to_s, val_io.to_s, map_ptag(char_half, count), 0)
  end

  def map_ptag(char : Char, count = 1)
    case char
    when '.', '-', '/'
      count < 2 ? PosTag::Number : count < 3 ? PosTag::Ntime : PosTag::Litstr
    else # ':'
      count < 3 ? PosTag::Ntime : PosTag::Litstr
    end
  end

  FULLWIDTH_GAP = 65248 # different in code point between half width and full width characters

  def map_letter(char : Char) : Char?
    return char if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
    return char - FULLWIDTH_GAP if (char >= 'ａ' && char <= 'ｚ') || (char >= 'Ａ' && char <= 'Ｚ')
    nil
  end

  def map_number(char : Char) : Char?
    return char if char >= '0' && char <= '9'
    return char - FULLWIDTH_GAP if char >= '０' && char <= '９'
    nil
  end

  def in_uri?(char : Char)
    {':', '/', '.', '?', '@', '=', '%', '+', '-', '~', '_'}.includes?(char)
  end
end
