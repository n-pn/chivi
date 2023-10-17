# require "tabkv"
# require "../../src/mt_v1/mt_core"

# output = Tabkv(Array(String)).new "var/vhint/names.tsv", mode: :reset

# manual = Tabkv(Array(String)).new "var/vhint/names-manual.tsv"

# INP = "_db/vpinit/qtrans/outerqt/names"

# files = {
#   "#{INP}/upper/names-upper-fixed.txt",
#   "#{INP}/mixed/names-mixed-fixed.txt",
# }

# files.each do |file|
#   File.read_lines(file).each do |line|
#     next if line.empty?
#     key, val = line.split('=', 2)
#     output.upsert(key, val.split('/'))
#   rescue err
#     puts err, line
#   end
# end

# RESOLVING = ARGV.includes?("--resolve")

# mydict = CV::VpDict.regular
# File.read_lines("_db/vpinit/bd_lac/out/book-names.txt").each do |name|
#   next unless term = mydict.find(name)
#   vals = term.val.reject { |x| x == x.downcase || x.downcase == CV::MtCore.cv_hanviet(name, false).downcase }
#   next if vals.empty? || vals.first.empty?

#   if checked = manual[name]?
#     puts "#{name}=#{checked.join('/')}".colorize.blue
#     output.upsert(name, checked)
#     next
#   end

#   if fixed = output[name]?
#     next if fixed.includes?(vals.first)

#     puts "#{name}=#{vals.join('/')} >> #{fixed.join('/')}".colorize.red
#     next unless RESOLVING

#     puts "https://www.google.com/search?q=#{name}"
#     print "1: keep old, 2: keep new, 3: old first, 4: new first, 5: prompt: "

#     case gets
#     when "1" then vals = vals.uniq!
#     when "2" then vals = fixed
#     when "3" then vals = vals.concat(fixed).uniq!
#     when "4" then vals = fixed.concat(vals).uniq!
#     else
#       vals = gets.not_nil!.split("|").map(&.strip)
#     end

#     manual.append!(name, vals)
#     output.upsert(name, vals)
#   elsif !term.val.first.empty?
#     puts "#{name}=#{term.val.join('/')}".colorize.green
#     output.upsert(name, term.val)
#   end
# end

# output.save!(clean: true)
