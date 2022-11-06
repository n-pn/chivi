require "../models/tl_term"

def cleanup(input : String)
  input.split("\\t")
    .join("; ")
    .gsub(/(\]|}); /) { |_, x| x[1] + " " }
end

terms = [] of TL::TlTerm

File.each_line("var/inits/system/trichdan.txt") do |line|
  key, vals = line.split("=", 2)
  vals = vals.split("\\n").map { |x| cleanup(x) }
  terms << TL::TlTerm.new(key, vals.join('\v'))
rescue err
  puts err
end

puts "input: #{terms.size}"

TL::TlTerm.init_db("trich_dan", reset: false)
TL::TlTerm.upsert_bulk("trich_dan", terms)
# TL::TlTerm.remove_dup!("trich_dan")
