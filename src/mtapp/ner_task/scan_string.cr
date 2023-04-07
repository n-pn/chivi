require "./entity_type"

module MT::BasicNER::ScanString
  extend self

  def scan_one(input : Array(Char), start : Int32 = 0)
    num_count = 0
    cap_count = 0

    url1_idx = 0
    url2_idx = 0

    index = start
    upper = input.size

    while index < upper
      char = input.unsafe_fetch(index)

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
      tag = EntityType::Name
    elsif num_count == 0
      tag = EntityType::Frgn
    else
      tag = EntityType::Misc
    end

    # puts ["scan_string", index, url1_idx, url2_idx]

    case
    when str_is_url1?(input, index, url1_idx)
      scan_link(input, index &+ 3)
    when str_is_url2?(input, index, url2_idx)
      scan_link(input, index &+ 2)
    else
      {index, tag, nil}
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

  private def str_is_url1?(input : Array(Char), index : Int32, url1_idx : Int32)
    return false unless url1_idx == 4 || url1_idx == 5
    return false unless index &+ 3 < input.size
    input[index] == ':' && input[index &+ 1] == '/' && input[index &+ 2] == '/'
  end

  private def str_is_url2?(input : Array(Char), index : Int32, url2_idx : Int32)
    return false unless url2_idx == 3
    return false unless index &+ 2 < input.size
    input[index] == '.' && input[index &+ 1].ascii_letter?
  end

  URL_CHARS = {
    '$', '!', '*', '@', '&',
    '%', '/', ':', '=', '?',
    '#', '+', '-', '_', '.',
    '~',
  }

  def scan_link(input : Array(Char), index : Int32 = 0)
    # puts ["scan_url", index]

    while index < input.size
      char = input.unsafe_fetch(index)
      index += 1

      case char
      when 'A'..'Z', '0'..'9', 'a'..'z', '_'
        next
      else
        break if index >= input.size || !URL_CHARS.includes?(char)
        char = input.unsafe_fetch(index)
        index += 1
        break unless char.ascii_alphanumeric?
      end
    end

    {index, EntityType::Link, nil}
  end
end
