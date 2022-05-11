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

out_dict = CV::VpHint.trungviet

File.each_line("_db/vpinit/system/lacviet-mtd.txt") do |line|
  key, vals = line.split("=", 2)
  vals = vals.split("\\n").map { |x| cleanup(x) }
  out_dict.add(key, vals)
rescue err
  puts err
end

out_dict.save!
