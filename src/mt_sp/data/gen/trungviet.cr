require "../wd_defn"

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

defns = [] of SP::WdDefn

File.each_line("var/inits/system/lacviet-mtd.txt") do |line|
  key, vals = line.split("=", 2)
  vals = vals.split("\\n").map { |x| cleanup(x) }.join('\n')
  defns << SP::WdDefn.new(key, vals)
rescue err
  puts err
end

puts "input: #{defns.size}"

SP::WdDefn.init_db("trungviet", reset: true)
SP::WdDefn.upsert("trungviet", defns)
# SP::WdDefn.remove_dup!("trungviet")
