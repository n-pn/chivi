require "../../_util/text_util"

class ZH::V1Text
  LIMIT = 3000
  UPPER = LIMIT * 1.5

  def self.split(input : String)
    c_len = TextUtil.clean_spaces(input).size
    p_len = c_len <= UPPER ? 1 : ((c_len - 1) // LIMIT) + 1

    limit = c_len // p_len

    chaps = [] of String
    count = 0

    lines = input.each_line
    title = lines.next.as(String).strip

    strio = String::Builder.new(title)

    lines.each do |line|
      line = line.strip
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
