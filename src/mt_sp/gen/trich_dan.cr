require "../data/lu_term"

def cleanup(input : String)
  input.split("\\t")
    .join("; ")
    .gsub(/(\]|}); /) { |_, x| x[1] + " " }
end

terms = [] of TL::LuTerm

File.each_line("var/inits/system/trichdan.txt") do |line|
  key, vals = line.split("=", 2)
  vals = vals.split("\\n").map { |x| cleanup(x) }
  terms << TL::LuTerm.new(key, vals.join('\v'))
rescue err
  puts err
end

puts "input: #{terms.size}"

TL::LuTerm.init_db("trich_dan", reset: false)
TL::LuTerm.upsert_bulk("trich_dan", terms)
# TL::LuTerm.remove_dup!("trich_dan")
