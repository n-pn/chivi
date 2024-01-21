require "icu"
require "colorize"

def clean_up(lines : Array(String))
  if lines.first.includes?("=========")
    lines.shift

    while line = lines.shift?
      break if line.includes?("=========")
    end

    if lines.last.includes?("=========")
      lines.pop

      while line = lines.pop?
        break if line.includes?("=========")
      end
    end
  end

  if lines[1].matches?(/^作者[[:punct:]]/)
    lines.shift
    lines.shift
  end

  while is_garbage?(lines.first)
    lines.shift
  end

  while is_garbage_end?(lines.last)
    lines.pop
  end

  lines
end

REGEXS = {
  /书名[[:punct:]]/,
  /作者[[:punct:]]/,
  /^分类[[:punct:]]/,
  /^字数[[:punct:]]/,
}

def is_garbage?(line : String)
  return true if is_garbage_end?(line)
  REGEXS.any?(&.matches?(line))
end

def is_garbage_end?(line : String)
  line.empty? || line.starts_with?("更多精校小说")
end

TEXT_DIR = "/www/chivi/xyz/seeds/zxcs.me/texts"
ORIG_DIR = "/www/chivi/xyz/seeds/zxcs.me/origs"

# CSDET = ICU::CharsetDetector.new

files = Dir.glob("#{TEXT_DIR}/*.txt.fix")

files.each do |fpath|
  fpath = fpath.sub(".fix", "")

  data = File.read_lines(fpath)
  next unless data[0].includes?("=======")

  puts fpath
  data = clean_up(data)
  File.write(fpath, data.join("\n"))
end
