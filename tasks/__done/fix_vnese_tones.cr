SUBS = {
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

def fix(file)
  input = File.read(file)

  SUBS.each do |k, v|
    input = input.gsub(k, v)
  end

  File.write(file + ".fixed", input)
end

fix("src/appcv/_fixes/vi_btitles.tsv")
