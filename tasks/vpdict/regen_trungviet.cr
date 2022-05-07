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

inp_dict = QtDict.load("system/lacviet-mtd.txt", preload: true)
out_dict = CV::VpHint.trungviet

puts "- input: #{inp_dict.size}"

inp_dict.data.each do |key, vals|
  vals = vals.first.split("\\n").map { |x| cleanup(x) }
  out_dict.add(key, vals)
rescue err
  puts err
end

out_dict.save!
