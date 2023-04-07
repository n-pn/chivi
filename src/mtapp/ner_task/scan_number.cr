require "../../../_util/char_util"
require "./entity_type"

module M2::BasicNER::ScanNumber
  extend self

  PROX_WORDS = {
    '来' => "chừng ",
    '余' => "trên ",
    '多' => "hơn ",
  }

  def scan_one(input : Array(Char), index : Int32 = 0)
    match_char = nil
    char_count = 1

    start = index
    upper = input.size

    while index < upper
      char = input.unsafe_fetch(index)

      case char
      when .ascii_letter?
        return scan_rawstr(input, index &+ 1)
      when '0'..'9', '_'
        index += 1
      when ','
        break unless index &+ 1 < upper
        break unless input.unsafe_fetch(index &+ 1).in?('0'..'9')
        index &+= 2
      when ':', '.', '-', '/', '~', '—'
        break unless index &+ 1 < upper
        break unless input.unsafe_fetch(index &+ 1).in?('0'..'9')

        if match_char
          return scan_rawstr(input, index &+ 2) unless char == match_char
          char_count &+= 1
        else
          match_char = char
        end

        index &+= 2
      else
        break
      end
    end

    tag = match_num_tag(match_char, char_count)
    return {index, tag, nil} unless EntityType.number?(tag)

    char = input.unsafe_fetch(index)

    if prox = PROX_WORDS[char]?
      val = prox + input[start...index].join
      tag = EntityType::Ndig
      index += 1
    end

    # FIXME: handle mixed ndigit + hannum

    {index, tag, val}
  end

  private def match_num_tag(char : Char?, count : Int32)
    # puts ["match_tag", char, count]
    case char
    when .nil? then EntityType::Ndig
    when '.'   then tag_for_num_with_period(count)
    when '/'   then tag_for_num_with_slash(count)
    when ':'   then tag_for_num_with_comma(count)
    when '-'   then tag_for_num_with_minus(count)
    when '~'   then tag_for_num_with_tilde(count)
    when '—'   then tag_for_num_with_dash(count)
    else            EntityType::Ndig # this should not happen
    end
  end

  @[AlwaysInline]
  private def tag_for_num_with_period(count : Int32) : Int32
    count < 2 ? EntityType::Ndig : count < 3 ? EntityType::Date : EntityType::Misc
  end

  @[AlwaysInline]
  private def tag_for_num_with_slash(count : Int32) : Int32
    count < 2 ? EntityType::Ndig : count < 3 ? EntityType::Date : EntityType::Misc
  end

  @[AlwaysInline]
  private def tag_for_num_with_comma(count : Int32) : Int32
    count < 3 ? EntityType::Time : EntityType::Misc
  end

  @[AlwaysInline]
  private def tag_for_num_with_minus(count : Int32) : Int32
    count == 3 ? EntityType::Date : EntityType::Math
  end

  @[AlwaysInline]
  private def tag_for_num_with_tilde(count : Int32) : Int32
    count == 1 ? EntityType::Ndig : EntityType::Misc
  end

  @[AlwaysInline]
  private def tag_for_num_with_dash(count : Int32) : Int32
    count == 1 ? EntityType::Ndig : EntityType::Misc
  end

  def scan_rawstr(input : Array(Char), index = 0)
    upper = input.size

    while index < upper
      char = input.unsafe_fetch(index)
      break unless char.ascii_alphanumeric?
      index += 1
    end

    {index, EntityType::Misc, nil}
  end
end
