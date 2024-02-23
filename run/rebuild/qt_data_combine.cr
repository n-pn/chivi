require "./_shared"

INP = "var/cvmtl/inits/vietphrase"
OUT = "var/dicts/_temp"

files = [] of String
files.concat Dir.glob("#{INP}/0-fixtures/*.txt")
files.concat Dir.glob("#{INP}/0-localqt/*.txt").sort!
files.concat Dir.glob("#{INP}/0-localqt/names/*.txt")
files.concat Dir.glob("#{INP}/0-localqt/names/fictions/*.txt")
files.concat Dir.glob("#{INP}/1-thtgiang/*.txt").sort!
files.concat Dir.glob("#{INP}/2-cvuser/*.txt").sort!
files.concat Dir.glob("#{INP}/3-unknown/*.txt").sort!

output = {} of String => Set(String)

files.each do |file|
  File.each_line(file) do |line|
    rows = line.split('=', 2)

    next unless vstrs = rows[1]?
    next if vstr.empty?

    zstr = CharUtil.canonize(rows[0]).strip
    output[zstr] ||= Set(String).new

    TextUtil.fix_viet(vstrs).split(/[\/\|]/).each do |vstr|
      output[zstr] << vstr.strip unless vstr.blank?
    end
  end

  puts "file: #{file}, output: #{output.size}"
end

out_path = "#{INP}/qt-combined.tsv"
File.open(out_path, "w") do |file|
  output.each do |vstr, vals|
    next if vals.empty?

    file << vstr << '\t'
    vals.join(file, '\t')
    file << '\n'
  end
end

puts "saved to: #{out_path}"
