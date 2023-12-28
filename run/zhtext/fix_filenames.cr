INP = "/www/var.chivi/zroot/rawtxt"
Dir.each_child(INP) do |child_dir|
  files = Dir.glob("#{INP}/#{child_dir}/**/*.db3.old")
  puts "#{child_dir}: #{files.size}"

  files.each do |old_file|
    new_file = old_file.sub(".old", "")
    File.rename(old_file, new_file)
    puts new_file
  rescue ex
    puts old_file
  end
end
