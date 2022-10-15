CHARS = {} of Char => String
WORDS = {} of String => String

def load_map(file : String)
  File.each_line(file) do |line|
    args = line.split('\t')
    next unless key = args[0]?
    next if key.empty?

    if val = args[1]?
      val = val.split('ǀ', 2).first
      if key.size > 1
        WORDS[key] = val
      else
        CHARS[key[0]] = val
      end
    elsif key.size > 1
      WORDS.delete(key)
    else
      CHARS.delete(key[0])
    end
  end
end

load_map("var/dicts/v1/other/pin_yin.tsv")
# load_map("var/dicts/v1/other/pin_yin.tab")

puts CHARS.size, WORDS.size

File.open("var/dicts/qtran/binh_am-chars.tsv", "w") do |io|
  CHARS.each do |k, v|
    io << k << '\t' << v << '\n'
  end
end

File.open("var/dicts/qtran/binh_am-words.tsv", "w") do |io|
  WORDS.each do |k, v|
    io << k << '\t' << v << '\n'
  end
end
