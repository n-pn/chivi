require "./utils/common"
require "./utils/clavis"

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

out_dict = Libcv::BaseDict.load("trungviet", mode: 0)
out_dict.load!(Utils.inp_path("initial/lacviet-mtd.txt"), legacy: true)

hv_chars = Clavis.load("hanviet/lacviet-chars.txt", false)
hv_words = Clavis.load("hanviet/lacviet-words.txt", false)

ondicts = Utils.ondicts_words

out_dict.each do |item|
  ondicts.upsert(item.key) if Utils.has_hanzi?(item.key)

  item.vals = item.vals.first.split("\\n").map { |x| cleanup(x) }
  item.vals.each do |val|
    if match = val.match(/{(.+?)}/)
      val = match[1].downcase

      if item.key.size > 1
        hv_words.upsert(item.key, [val])
      else
        vals = val.split(/[,;]\s*/)
        hv_chars.upsert(item.key, vals)
      end
    end
  end
end

out_dict.save!
hv_chars.save!
hv_words.save!
ondicts.save!
