# require "./shared/cvdict"

require "./_utils/common"

def cleanup(defs : String)
  defs.split("\\t")
    .map(&.gsub(/^\d+\.\s*/, "").gsub(/\.\s*$/, ""))
    .reject(&.empty?)
    .join("; ")
    .sub("]; ", "] ")
    .sub("}; ", "} ")
    .split("; ")
    .uniq
    .join("; ")
end

OUT_FILE = Common.out_path("lookup/lacviet.dic")

out_dict = DictRepo.new(OUT_FILE, false)
out_dict.load_legacy!(Common.inp_path("_system/lacviet.txt"))

char_dict = DictRepo.new(Common.tmp_path("hanviet/lacviet-chars.dic"))
word_dict = DictRepo.new(Common.tmp_path("hanviet/lacviet-words.dic"))

out_dict.each do |item|
  Common.add_to_known(item.key)

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
Common.save_known_words!
