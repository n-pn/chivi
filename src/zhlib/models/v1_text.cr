class ZH::V1Text
  LIMIT = 3000
  UPPER = LIMIT * 1.5

  def self.split(input : String)
    c_len = input.size
    return {c_len, [input]} if c_len <= UPPER

    p_len = ((c_len - 1) // LIMIT) + 1
    limit = c_len // p_len

    chaps = [] of String
    count = 0

    line_iter = input.each_line

    title = line_iter.next.as(String)
    strio = String::Builder.new(title)

    line_iter.each do |line|
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
