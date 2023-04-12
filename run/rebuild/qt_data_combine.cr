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

FIX_TONE_MARKS = {
  "òa" => "oà",
  "óa" => "oá",
  "ỏa" => "oả",
  "õa" => "oã",
  "ọa" => "oạ",

  "òe" => "oè",
  "óe" => "oé",
  "ỏe" => "oẻ",
  "õe" => "oẽ",
  "ọe" => "oẹ",

  "ùy" => "uỳ",
  "úy" => "uý",
  "ủy" => "uỷ",
  "ũy" => "uỹ",
  "ụy" => "uỵ",
}

REGEX = Regex.new(FIX_TONE_MARKS.keys.join('|'))

def correcting(val : String)
  val = val.unicode_normalize(:nfkc)
  val.gsub(REGEX) { |str| FIX_TONE_MARKS[str] }
end

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

files.each do |file|
  File.each_line(file) do |line|
    rows = line.split('=', 2)

    next unless vals = rows[1]?
    next if vals.empty?

    key = normalize(rows[0]).strip
    output[key] ||= Set(String).new

    correcting(vals).split(/\/|\|/).each do |val|
      output[key] << val.strip unless val.blank?
    end
  end

  puts "file: #{file}, output: #{output.size}"
end

out_path = "#{INP}/qt-combined.tsv"
File.open(out_path, "w") do |file|
  output.each do |key, vals|
    next if vals.empty?

    file << key << '\t'
    vals.join(file, '\t')
    file << '\n'
  end
end

puts "saved to: #{out_path}"
