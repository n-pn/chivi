output = {} of String => Array(String)

DIR = "var/dicts/_temp"

File.each_line("#{DIR}/generic.tsv") do |line|
  vals = line.split('\t')
  output[vals.shift] = vals
end

File.each_line("#{DIR}/from_qt.tsv") do |line|
  vals = line.split('\t')
  arr = output[vals.shift] ||= [] of String

  lower, upper = vals.partition { |x| x == x.downcase }
  vals = lower.concat(upper)

  arr.concat(vals)
end

File.each_line("#{DIR}/special.tsv") do |line|
  vals = line.split('\t')

  arr = output[vals.shift] ||= [] of String
  arr.concat(vals)
end

puts "total: #{output.size}"

File.open("#{DIR}/combined.tsv", "w") do |file|
  output.each do |key, vals|
    next if vals.first.empty?
    file << key << '\t' << vals.uniq!.join('\t') << '\n'
  end
end
