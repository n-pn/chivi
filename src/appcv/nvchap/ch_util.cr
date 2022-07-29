module CV::ChUtil
  extend self

  LIMIT = 3000

  def split_parts(lines : Array(String)) : {Int16, Array(String)}
    sizes = lines.map(&.size)
    chars = sizes.sum.to_i16

    return {chars, [lines.join('\n')]} if chars <= LIMIT * 1.5

    parts = (chars / LIMIT).round.to_i8
    limit = chars // parts

    title = lines[0]
    strio = String::Builder.new(title)

    count, cpart = 0, 0_i16
    chaps = [] of String

    1.upto(lines.size - 1) do |idx|
      strio << "\n" << lines.unsafe_fetch(idx)

      count += sizes[idx]
      next if count < limit

      chaps << strio.to_s
      cpart += 1_i16

      strio = String::Builder.new(title)
      count = 0
    end

    chaps << strio.to_s if count > 0
    {chars, chaps}
  end

  struct Chap
    getter chvol : String
    getter lines = [] of String
    getter title : String { lines.first? || "" }

    def initialize(@chvol)
    end
  end

  LINE_RE = /^\/{3,}(.*)$/

  def split_chaps(input : Array(String), chvol = "")
    chaps = [Chap.new(chvol)]

    input.each do |line|
      if match = LINE_RE.match(line)
        extra = match[1].strip
        chvol = extra unless extra.empty?

        chaps << Chap.new(chvol)
      else
        line = line.strip
        chaps.last.lines << line unless line.empty?
      end
    end

    chaps.shift if chaps.first.lines.empty?
    chaps
  end
end
