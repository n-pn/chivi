require "./utils/common"

def cleanup(input : String)
  input.split("\\t")
    .map(&.gsub(/^\d+\.\s*/, "").gsub(/\.\s*$/, ""))
    .reject(&.empty?)
    .join("; ")
    .sub("]; ", "] ")
    .sub("}; ", "} ")
    .split("; ")
    .uniq
    .join("; ")
end

OUT_FILE = Utils.out_path("trungviet.dic")

out_dict = DictRepo.new(OUT_FILE, false)
out_dict.load_legacy!(Utils.inp_path("initial/lacviet-mtd.txt"))

char_dict = DictRepo.new(Utils.inp_path("autogen/lacviet-chars.dic"))
word_dict = DictRepo.new(Utils.inp_path("autogen/lacviet-words.dic"))

knowns = Utils.known_words

out_dict.each do |item|
  knowns.upsert(item.key) if Utils.has_hanzi?(item.key)

  item.vals = item.vals.first.split("\\n").map { |x| cleanup(x) }
  item.vals.each do |val|
    if match = val.match(/{(.+)}/)
      val = match[1].downcase

      if item.key.size > 1
        word_dict.upsert(item.key, [val])
      else
        vals = val.split(/[,;]\s*/)
        char_dict.upsert(item.key) do |node|
          node.vals.concat(vals)
        end
      end
    end
  end
end

out_dict.save!
char_dict.save!
word_dict.save!
knowns.save!
