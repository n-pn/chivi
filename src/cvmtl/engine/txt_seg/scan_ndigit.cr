require "../../../_util/char_util"

class MT::TxtSeg
  def scan_ndigit(index : Int32 = 0)
    match_char = nil
    char_count = 1

    while index < @upper
      char = @mtl_chars.unsafe_fetch(index)

      case char
      when .ascii_letter?
        return scan_rawstr(index &+ 1)
      when '0'..'9', '_' then index += 1
      when ':', '.', '-', '/', '~', '—'
        break unless index &+ 1 < @upper
        break unless @mtl_chars.unsafe_fetch(index &+ 1).in?('0'..'9')

        if match_char
          return scan_rawstr(index &+ 2) unless char == match_char
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
    {index, tag}
  end

  private def match_num_tag(char : Char?, count : Int32)
    # puts ["match_tag", char, count]
    case char
    when .nil? then MtlTag::Ndigit0
    when '.'   then tag_for_num_with_period(count)
    when '/'   then tag_for_num_with_slash(count)
    when ':'   then tag_for_num_with_comma(count)
    when '-'   then tag_for_num_with_minus(count)
    when '~'   then tag_for_num_with_tilde(count)
    when '—'   then tag_for_num_with_dash(count)
    else            MtlTag::Numeric # this should not happen
    end
  end

  @[AlwaysInline]
  private def tag_for_num_with_period(count : Int32) : MtlTag
    count < 2 ? MtlTag::Ndigit1 : count < 3 ? MtlTag::Tdate : MtlTag::StrOther
  end

  @[AlwaysInline]
  private def tag_for_num_with_slash(count : Int32) : MtlTag
    count < 2 ? MtlTag::Ndigit2 : count < 3 ? MtlTag::Tdate : MtlTag::StrOther
  end

  @[AlwaysInline]
  private def tag_for_num_with_comma(count : Int32) : MtlTag
    count < 3 ? MtlTag::Ttime : MtlTag::StrOther
  end

  @[AlwaysInline]
  private def tag_for_num_with_minus(count : Int32) : MtlTag
    count == 3 ? MtlTag::Tdate : MtlTag::StrOther
  end

  @[AlwaysInline]
  private def tag_for_num_with_tilde(count : Int32) : MtlTag
    count == 1 ? MtlTag::Ndigit3 : MtlTag::StrOther
  end

  @[AlwaysInline]
  private def tag_for_num_with_dash(count : Int32) : MtlTag
    count == 1 ? MtlTag::Ndigit3 : MtlTag::StrOther
  end

  def scan_rawstr(index = 0)
    while index < @upper
      char = @mtl_chars.unsafe_fetch(index)
      break unless char.ascii_alphanumeric?
      index += 1
    end

    {index, MtlTag::StrOther}
  end
end
