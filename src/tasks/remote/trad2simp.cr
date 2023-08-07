INP = "var/.keep/rmbook/www.hotupub.net"
OUT = "var/.keep/rmbook/www.hotupub.fix"

files = Dir.glob("#{INP}/*.htm")

files.each do |inp_file|
  out_file = inp_file.sub(INP, OUT)

  `opencc -c hk2s.json -i '#{inp_file}' -o '#{out_file}'`
  puts "#{inp_file} => #{out_file}"
end
