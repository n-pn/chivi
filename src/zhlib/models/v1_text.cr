require "../../_util/text_util"

class ZH::V1Text
  LIMIT = 3000
  UPPER = LIMIT * 1.5

  def self.split(input : String)
    lines = TextUtil.clean_spaces(input).split(/\r\n?|\n/).reject!(&.empty?)
    clean(lines)
  end

  def self.split(lines : Array(String))
    c_len = input.size
    return {c_len, [lines.join('\n')]} if c_len <= UPPER

    p_len = ((c_len - 1) // LIMIT) + 1
    limit = c_len // p_len

    chaps = [] of String
    count = 0

    title = lines.shift
    strio = String::Builder.new(title)

    lines.each do |line|
      line = line.rstrip
      next if line.empty?

      strio << '\n' << line
      count += line.size

      next unless count > limit
      count = 0

      chaps << strio.to_s
      strio = String::Builder.new(title)
    end

    chaps << strio.to_s if count > 0
    {c_len, chaps}
  end
end
