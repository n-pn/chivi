require "./shared/qt_util"
require "./shared/qt_dict"

def cleanup(input : String)
  input.split("\\t")
    .map(&.gsub(/^\d+\.\s*/, "").gsub(/\.\s*$/, ""))
    .reject(&.empty?)
    .join("; ")
    .gsub("]; ", "] ")
    .gsub("}; ", "} ")
    .split(/;\s+/)
    .uniq
    .join("; ")
end

inp_dict = QtDict.load("_system/lacviet-mtd.txt", preload: true)
hv_chars = QtDict.load("hanviet/lacviet-chars.txt", preload: false)
hv_words = QtDict.load("hanviet/lacviet-words.txt", preload: false)
out_dict = CV::Vdict.load("trungviet", reset: true)

puts "- input: #{inp_dict.size}"
inp_dict.data.each do |key, vals|
  QtUtil.lexicon.add(key) if QtUtil.has_hanzi?(key)

  vals = vals.first.split("\\n").map { |x| cleanup(x) }
  out_dict.set(key, vals)

  vals.each do |val|
    if match = val.match(/{(.+?)}/)
      val = match[1].downcase

      if key.size > 1
        hv_words.set(key, [val])
      else
        vals = val.split(/[,;]\s*/)
        hv_chars.set(key, vals)
      end
    end
  end
rescue err
  p! [key, vals]
  puts err
end

hv_chars.save!
hv_words.save!
out_dict.save!(prune: false)

QtUtil.lexicon.save!
