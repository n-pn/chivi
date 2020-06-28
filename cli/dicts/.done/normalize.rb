files = Dir.glob("var/libcv/.inits/**/*.txt")

files.each_with_index do |file, idx|
  puts "- #{idx}: #{file}"
  text = File.read(file)
  text = text.unicode_normalize(:nfkc)
  File.write(file, text)
rescue => err
  puts err
  puts file
end
