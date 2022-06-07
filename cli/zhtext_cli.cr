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

class CV::Zhtext
  def initialize(@sname : String, @snvid : String, @pgidx : Int32)
    @chdir = "var/chtexts/#{@sname}/#{@snvid}/#{@pgidx}"
    Dir.mkdir_p(@chir)
  end

  def save_chap!(schid : String, input : Array(String), zipping = true) : Nil
    return if input.empty?
    chars, parts = split_parts(input)

    parts.each_with_index do |text, part|
      File.write("#{@chdir}/#{schid}-#{part}.txt", text)
    end

    `zip --include=\\*.txt -rjmq #{@chdir}.zip #{@chdir}` if zipping
    puts "#{chars}\t#{parts.size}"
  end

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
    parts = [] of String

    1.upto(lines.size - 1) do |idx|
      strio << "\n" << lines.unsafe_fetch(idx)

      count += sizes[idx]
      next if count < limit

      parts << strio.to_s
      cpart += 1

      strio = String::Builder.new(title)
      count = 0
    end

    parts << strio.to_s if count > 0
    {chars, parts}
  end
end
