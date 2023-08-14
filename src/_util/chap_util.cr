require "./char_util"
require "./text_util"

module ChapUtil
  extend self

  def clean_zchdiv(chdiv : String)
    chdiv = chdiv.gsub(/《.*》/, "").gsub(/\n|\t|\s{2,}/, '　')
    TextUtil.canon_clean(chdiv)
  end

  NUMS = "零〇一二两三四五六七八九十百千"
  VOLS = "集卷季"

  DIVS = {
    /^(第?[#{NUMS}\d]+[#{VOLS}].*?)(第?[#{NUMS}\d]+[章节幕回折].*)$/,
    # /^(第?[#{NUMS}\d]+[#{VOLS}].*?)(（\p{N}+）.*)$/,
    /^【(第?[#{NUMS}\d]+[#{VOLS}])】(.+)$/,
  }

  def split_ztitle(title : String, chdiv = "") : Tuple(String, String)
    title = TextUtil.canon_clean(title)
    return {title, chdiv} unless chdiv.empty?

    DIVS.each do |regex|
      next unless match = regex.match(title)
      title = match[2].lstrip('　')
      chdiv = match[1].rstrip('　')
      break
    end

    {title, chdiv}
  end

  alias SplitOutput = {Array(String), Array(Int32), UInt32}

  # split raw chapter text to multi parts
  # return parts (with title as first element), sizes of each part
  # and the checksum for the content (unique for part spliting)
  def split_rawtxt(lines : Array(String), title : String = lines.shift) : SplitOutput
    parts = [title]
    sizes = [title.size]

    cksum = calc_cksum(title)
    return {parts, sizes, cksum} if lines.empty?

    limit = char_limit(lines.sum(&.size))
    cksum = calc_cksum('\n', cksum)

    cpart = String::Builder.new
    count = 0

    lines.each do |line|
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

  CHAR_LIMIT = 2048
  CHAR_UPPER = 3200

  @[AlwaysInline]
  def char_limit(char_count : Int32)
    char_count < CHAR_UPPER ? CHAR_UPPER : char_count // (char_count / CHAR_LIMIT).round.to_i
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
  def cksum_to_s(cksum : UInt32)
    # NOTE: this is actually not cover the whole range of UInt32, as it can
    # only represent 32 ** 6 = 1073741824 integers
    # but as the chapter count for each novel is as most 10000
    # it does not matter much
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

  # puts calc_cksum("1234")
end
