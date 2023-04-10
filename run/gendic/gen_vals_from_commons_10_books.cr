DIR = "var/dicts"

commons = Set(String).new

File.each_line("#{DIR}/inits/in-10-books.tsv") do |line|
  key = line.split('\t').first
  commons << key
end

puts "input: #{commons.size}"

output = {} of String => Array(String)

File.each_line("#{DIR}/_temp/combined.tsv") do |line|
  vals = line.split('\t')
  key = vals.shift
  next unless commons.includes?(key)
  output[key] = vals.first(3)
end

puts "output: #{output.size}"

File.open("#{DIR}/_temp/essential.tsv", "w") do |file|
  output.each do |key, vals|
    file << key << '\t' << vals.join('ǀ') << '\n'
  end
end

File.open("#{DIR}/_temp/VietPhrase.txt", "w") do |file|
  output.each do |key, vals|
    file << key << '=' << vals.join('/') << '\n'
  end
end
