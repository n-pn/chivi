require "./shared/cvdict"

INP_DIR = File.join("data", ".inits", "dic-inp")
OUT_DIR = File.join("data", "cv_dicts")

SEP_0 = "ǁ"
SEP_1 = "¦"
SEP_2 = "|"

def cleanup(val)
  val.split("\\t")
    .map(&.sub(/^\d+\.\s+/, "").sub(/\.\s*$/, ""))
    .reject(&.empty?)
    .join("; ")
    .sub("]; ", "] ")
    .sub("}; ", "} ")
    .split("; ")
    .uniq
    .join("; ")
end

input = File.read_lines("#{INP_DIR}/routine/lacviet.txt")
output = File.open("#{OUT_DIR}/trungviet.dic", "w")

chars = Cvdict.new("#{INP_DIR}/hanviet/lacviet/chars.txt")
words = Cvdict.new("#{INP_DIR}/hanviet/lacviet/words.txt")

input.each do |line|
  line = line.strip
  next if line.empty?

  key, val = line.split("=", 2)
  vals = val.split("\\n").map { |x| cleanup(x) }
  output << key << SEP_0 << vals.join(SEP_1) << "\n"

  vals.each do |val|
    if match = val.match(/{(.+)}/)
      han = match[1].downcase

      if key.size > 1
        words.add(key, han)
      else
        han = han.split(/[,;]\s/).join("/")

        chars.add(key, han)
      end
    end
  end
end

output.close

chars.save!
words.save!
