files = Dir.glob("var/appcv/.cached/qu_la/infos/*")
# files.sort_by! { |x| File.basename(x,".html").to_i}

files.each do |file|
  next unless File.size(file) == 317
  puts file
  File.delete(file)
end
