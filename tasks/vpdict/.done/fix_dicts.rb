MAP = {
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

def fix_word(text)
  MAP.each { |key, val| text.gsub!(key, val) }
  text
end

def fix_files(files)
  files.each_with_index do |file, idx|
    puts "- #{idx}: #{file}"
    text = File.read(file, encoding: "UTF-8")
    text = text.unicode_normalize(:nfkc)

    File.write(file, fix_word(text))
  rescue => err
    puts err
    puts file
  end
end

fix_files Dir.glob("_db/vpinit/qtrans/outerqt/**/*.txt")
