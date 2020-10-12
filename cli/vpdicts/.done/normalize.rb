files = Dir.glob("var/.dict_inits/**/*.txt")

map = {
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

files.each_with_index do |file, idx|
  puts "- #{idx}: #{file}"
  text = File.read(file)
  text = text.unicode_normalize(:nfkc)

  map.each do |key, val|
    text.gsub(key, val)
  end

  File.write(file, text)
rescue => err
  puts err
  puts file
end
