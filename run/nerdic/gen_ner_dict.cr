DIR = "var/mtdic/fixed/zners"

out_file = File.open("#{DIR}/translit.tsv", "w")
at_exit { out_file.close }

('0'..'9').each do |digit|
  out_file << digit << '\t'
  out_file << "FRAG WORD LINK-IE DINT MATH"
  out_file << '\t' << digit << '\n'
end

('a'..'z').each do |digit|
  out_file << digit << '\t'
  out_file << "FRAG WORD LINK-IE"
  out_file << '\t' << digit << '\n'
end

('A'..'Z').each do |digit|
  out_file << digit << '\t'
  out_file << "FRAG WORD LINK-IE"
  out_file << '\t' << digit << '\n'
end

URL_CHARS = {
  '$', '!', '*', '@', '&',
  '%', '/', ':', '=', '?',
  '#', '+', '-', '_', '.',
  '~',
}

URL_CHARS.each do |char|
  out_file << char << '\t'
  out_file << "FRAG-I LINK-I"
  out_file << '\t' << char << '\n'
end

# out_file << " \t FRAG-I\t \n"

out_file << "https://\tLINK-B\thttps://\n"
out_file << "http://\tLINK-B\thttp://\n"
out_file << "www.\tLINK-B\twww.\n"
