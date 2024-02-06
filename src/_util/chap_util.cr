require "./char_util"
require "./text_util"

module ChapUtil
  extend self

  def clean_zchdiv(chdiv : String)
    chdiv = chdiv.gsub(/《.*》/, "").gsub(/\n|\t|\s{2,}/, '　')
    TextUtil.canon_clean(chdiv)
  end

  ###

  NUMS = "零〇一二两三四五六七八九十百千"
  VOLS = "集卷季"

  DIVS = {
    /^(第?[#{NUMS}\d]+[#{VOLS}].*?)(第?[#{NUMS}\d]+[章节幕回折].*)$/,
    # /^(第?[#{NUMS}\d]+[#{VOLS}].*?)(（\p{N}+）.*)$/,
    /^【(第?[#{NUMS}\d]+[#{VOLS}])】(.+)$/,
  }

  def split_ztitle(title : String, chdiv = "", cleaned : Bool = false) : Tuple(String, String)
    title = TextUtil.canon_clean(title) unless cleaned
    return {title, chdiv} unless chdiv.empty?

    DIVS.each do |regex|
      next unless match = regex.match(title)
      title = match[2].lstrip('　')
      chdiv = match[1].rstrip('　')
      break
    end

    {title, chdiv}
  end

  ###

  def split_lines(ztext : String)
    lines = [] of String
    ztext.each_line { |line| lines << TextUtil.canon_clean(line) unless line.blank? }
    lines
  end

  ##

  alias SplitOutput = {Array(String), Array(Int32), UInt32}

  # split raw chapter text to multi parts
  # return parts (with title as first element), sizes of each part
  # and the checksum for the content (unique for part spliting)
  def split_parts(paras : Array(String), title : String = paras.shift) : SplitOutput
    parts = [title]
    sizes = [title.size]

    cksum = calc_cksum(title)
    return {parts, sizes, cksum} if paras.empty?

    limit = char_limit(paras.sum(&.size))
    cksum = calc_cksum('\n', cksum)

    cpart = String::Builder.new
    count = 0

    paras.each do |line|
      cksum = calc_cksum('\n', cksum)
      cksum = calc_cksum(line, cksum)

      cpart << '\n' unless count == 0
      cpart << line

      count &+= line.size
      next if count < limit

      cksum = calc_cksum('\n', cksum)

      parts << cpart.to_s
      sizes << count

      cpart = String::Builder.new
      count = 0
    end

    if count > 0
      parts << cpart.to_s
      sizes << count
    end

    {parts, sizes, cksum}
  end

  CHAR_LIMIT = 32768
  CHAR_UPPER = 49152

  @[AlwaysInline]
  def char_limit(char_count : Int32)
    char_count < CHAR_UPPER ? CHAR_UPPER : char_count // (char_count / CHAR_LIMIT).round.to_i
  end

  def split_cztext(paras : Array(String), title : String = paras.shift)
    parts = String::Builder.new(title)
    sizes = String::Builder.new(title.size.to_s)

    if paras.empty?
      return {parts.to_s, sizes.to_s, calc_cksum(title).to_i64}
    end

    zlens = paras.map(&.size)
    limit = char_limit(zlens.sum)

    count = 0

    paras.each_with_index do |line, l_id|
      parts << '\n' if count == 0
      parts << '\n' << line

      count &+= zlens[l_id]
      next if count < limit

      sizes << ' ' << count.to_s
      count = 0
    end

    parts = parts.to_s
    sizes << ' ' << count if count > 0

    {parts, sizes.to_s, calc_cksum(parts).to_i64}
  end

  # 1.to(100) do |x|
  #   puts [x * 100, char_limit(x * 100)]
  # end

  BASIS_32 = 0x811c9dc5_u32
  PRIME_32 =   16777619_u32
  MASK_32  = 4294967295_u32

  @[AlwaysInline]
  def calc_cksum(input : String, cksum : UInt32 = BASIS_32)
    input.each_char { |char| cksum = calc_cksum(char, cksum) }
    cksum
  end

  @[AlwaysInline]
  def calc_cksum(input : Char, cksum : UInt32 = BASIS_32)
    ((cksum ^ input.ord) &* PRIME_32) & MASK_32
  end

  @[AlwaysInline]
  def calc_cksum(input : Array(String), cksum = BASIS_32)
    input.each_with_index do |cpart, index|
      cksum = calc_cksum("\n\n", cksum) if index > 0
      cksum = calc_cksum(cpart, cksum)
    end

    cksum
  end

  def cksum_to_s(cksum : UInt32 | Int64)
    # NOTE: this is actually not cover the whole range of UInt32, as it can
    # only represent 32 ** 6 = 1073741824 integers
    # but as we save chapter with both checksum and chap id number, it does not
    # really matter
    # if we use 7 characters then there will be chance when it overflow the UInt32
    # limit when we convert this back to integer for fast comparision,
    # so it is not worth it to add an extra character

    String.build do |io|
      6.times do
        digit = cksum % 32
        io << (digit < 10 ? '0' : 'W') + digit
        cksum //= 32
      end
    end
  end
end
