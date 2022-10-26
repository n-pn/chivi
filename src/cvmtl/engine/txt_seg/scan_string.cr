require "../../../_util/char_util"

class MT::TxtSeg
  def scan_string(index : Int32 = 0)
    num_count = 0
    cap_count = 0

    url1_idx = 0
    url2_idx = 0

    while index < @upper
      char = @mtl_chars.unsafe_fetch(index)

      case char
      when 'A'..'Z'
        cap_count &+= 1
      when '0'..'9'
        num_count &+= 1
      when 'a'..'z'
        url1_idx = check_url1(url1_idx, char)
        url2_idx = check_url2(url2_idx, char)
      else
        break unless char == '_'
      end

      index += 1
    end

    if cap_count > 0
      tag = MtlTag::OtherName
    elsif num_count > 0
      tag = MtlTag::LitBlank
    else
      tag = MtlTag::Noun
    end

    # puts ["scan_string", index, url1_idx, url2_idx]

    if str_is_url1?(index, url1_idx)
      scan_urlstr(index &+ 3)
    elsif str_is_url2?(index, url2_idx)
      scan_urlstr(index &+ 2)
    else
      {index, tag}
    end
  end

  URL1 = {'h', 't', 't', 'p', 's'}

  @[AlwaysInline]
  private def check_url1(idx : Int32, char : Char)
    idx > 4 || URL1.unsafe_fetch(idx) != char ? 99 : idx &+ 1
  end

  URL2 = {'w', 'w', 'w'}

  @[AlwaysInline]
  private def check_url2(idx : Int32, char : Char)
    idx > 2 || URL2.unsafe_fetch(idx) != char ? 99 : idx &+ 1
  end

  private def str_is_url1?(index : Int32, url1_idx : Int32)
    return false unless url1_idx == 4 || url1_idx == 5
    return false unless index &+ 3 < @upper
    @mtl_chars[index] == ':' && @mtl_chars[index &+ 1] == '/' && @mtl_chars[index &+ 2] == '/'
  end

  private def str_is_url2?(index : Int32, url2_idx : Int32)
    return false unless url2_idx == 3
    return false unless index &+ 2 < @upper
    @mtl_chars[index] == '.' && @mtl_chars[index &+ 1].ascii_letter?
  end

  def scan_urlstr(index : Int32 = 0)
    # puts ["scan_url", index]

    while index < @upper
      char = @mtl_chars.unsafe_fetch(index)
      index += 1

      case char
      when 'A'..'Z', '0'..'9', 'a'..'z', '_'
        next
      else
        break if index == @upper || !CharUtil.allowed_in_url?(char)
        char = @mtl_chars.unsafe_fetch(index)
        index += 1
        break unless char.ascii_alphanumeric?
      end
    end

    {index, MtlTag::StrLink}
  end
end
