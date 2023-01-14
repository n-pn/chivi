require "../data/lu_term"

def cleanup(input : String)
  input.split("\\t")
    .map(&.gsub(/^\d+\.\s*/, "").gsub(/\.\s*$/, ""))
    .reject(&.empty?)
    .join("; ")
    .gsub("]; ", "] ")
    .gsub("}; ", "} ")
    .split(/;\s*/)
    .uniq
    .join("; ")
end

terms = [] of TL::LuTerm

File.each_line("var/inits/system/lacviet-mtd.txt") do |line|
  key, vals = line.split("=", 2)
  vals = vals.split("\\n").map { |x| cleanup(x) }
  vals.each { |val| terms << TL::LuTerm.new(key, val) }
rescue err
  puts err
end

puts "input: #{terms.size}"

TL::LuTerm.init_db("trungviet", reset: false)
TL::LuTerm.upsert_bulk("trungviet", terms)
# TL::LuTerm.remove_dup!("trungviet")
