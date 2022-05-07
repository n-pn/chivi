require "./shared/qt_util"
require "./shared/qt_dict"

def cleanup(input : String)
  input.split("\\t")
    .join("; ")
    .gsub(/(\]|}); /) { |_, x| x[1] + " " }
end

inp_dict = QtDict.load("system/trichdan.txt", preload: true)
out_dict = CV::VpHint.trich_dan

puts "- input: #{inp_dict.size}"

inp_dict.data.each do |key, vals|
  vals = vals.first.split("\\n").map { |x| cleanup(x) }
  out_dict.add(key, vals)
rescue err
  puts err
end

out_dict.save!
