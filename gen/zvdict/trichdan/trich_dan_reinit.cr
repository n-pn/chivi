require "../../src/mt_sp/data/wd_defn"

def cleanup(input : String)
  input.split("\\t")
    .join("; ")
    .gsub(/(\]|}); /) { |_, x| x[1] + " " }
end

defns = [] of SP::WdDefn

File.each_line("var/cvmtl/spdic/trichdan.txt") do |line|
  key, vals = line.split("=", 2)
  vals = vals.split("\\n").map { |x| cleanup(x) }
  defns << SP::WdDefn.new(key, vals.join('\n'))
rescue err
  puts err
end

puts "input: #{defns.size}"

SP::WdDefn.init_db("trich_dan", reset: true)
SP::WdDefn.upsert("trich_dan", defns)
# SP::WdDefn.remove_dup!("trich_dan")
