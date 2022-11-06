require "../models/tl_term"

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

terms = [] of TL::TlTerm

File.each_line("var/inits/system/lacviet-mtd.txt") do |line|
  key, vals = line.split("=", 2)
  vals = vals.split("\\n").map { |x| cleanup(x) }

  terms << TL::TlTerm.new(key, vals.join('\v'))
rescue err
  puts err
end

puts "input: #{terms.size}"
TL::TlTerm.init_db("trungviet", reset: true)
TL::TlTerm.upsert_bulk("trungviet", terms)
