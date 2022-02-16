module CV::ChUtil
  extend self

  LIMIT = 3000

  def split_parts(lines : Array(String)) : {Int32, Array(String)}
    sizes = lines.map(&.size)
    chars = sizes.sum

    return {chars, [lines.join('\n')]} if chars <= LIMIT * 1.5

    parts = (chars / LIMIT).round.to_i
    limit = chars // parts

    title = lines[0]
    strio = String::Builder.new(title)

    count, cpart = 0, 0
    chaps = [] of String

    lines.each_with_index do |line, idx|
      strio << "\n" << line
      count += sizes[idx]
      next if count < limit

      chaps << strio.to_s
      cpart += 1

      strio = String::Builder.new(title)
      count = 0
    end

    chaps << strio.to_s if count > 0
    {chars, chaps}
  end
end
