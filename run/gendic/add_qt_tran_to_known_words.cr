def normalize(key : String)
  String.build do |io|
    key.each_char do |char|
      if (char.ord & 0xff00) == 0xff00
        io << (char.ord - 0xfee0).chr.downcase
      else
        io << char.downcase
      end
    end
  end
end

DICT = {} of String => String

File.each_line("var/cvmtl/vietphrase/combine-cleaned.tsv") do |line|
  next if line.empty?
  key, val = line.split('\t', 2)
  DICT[key] = val
end

out_file = File.open("var/mtdic/fixed/hints.tsv", "w")
existing = 0

File.each_line("var/cvmtl/known/all-known.tsv") do |key|
  key = normalize(key)
  next unless val = DICT[key]?

  existing += 1
  out_file << key << '\t' << val << '\n'
end

puts existing
out_file.close
