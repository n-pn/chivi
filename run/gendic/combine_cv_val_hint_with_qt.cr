output = {} of String => Array(String)

File.each_line("var/dicts/_temp/generic.tsv") do |line|
  vals = line.split('\t')
  output[vals.shift] = vals
end

File.each_line("var/dicts/_temp/special.tsv") do |line|
  vals = line.split('\t')

  arr = output[vals.shift] ||= [] of String
  arr.concat(vals)
end

File.each_line("var/dicts/_temp/from_qt.tsv") do |line|
  vals = line.split('\t')
  arr = output[vals.shift] ||= [] of String
  arr.concat(vals)
end

puts "total: #{output.size}"

File.open("var/dicts/_temp/combined.tsv", "w") do |file|
  output.each do |key, vals|
    next if vals.first.empty?
    file << key << '\t' << vals.uniq!.join('\t') << '\n'
  end
end
