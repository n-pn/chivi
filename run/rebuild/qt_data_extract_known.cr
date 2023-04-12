require "./_shared"

knowns = File.read_lines("var/cvmtl/known/all-known.tsv").map { |x| normalize(x) }.to_set

out_file = File.open("var/dicts/_temp/qt-known.tsv", "w")
existing = 0

File.each_line("var/dicts/_temp/qt-cleaned.tsv") do |line|
  next if line.empty?
  zstr, vstr = line.split('\t', 2)

  next unless knowns.includes? normalize(zstr)

  out_file.puts(line)
  existing += 1
end

puts existing
out_file.close
