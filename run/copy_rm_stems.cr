STEM_INP = "/2tb/var.chivi/rm_db/stems"

STEM_OUT = "/2tb/var.chivi/stems"

Dir.each_child(STEM_INP) do |child|
  inp_dir = "#{STEM_INP}/#{child}"
  out_dir = "#{STEM_OUT}/rm#{child}"
  Dir.mkdir_p(out_dir)

  Dir.children(inp_dir).each do |db_file|
    inp_file = "#{inp_dir}/#{db_file}"
    out_file = "#{out_dir}/#{db_file.sub(".db3", "-cinfo.db3")}"

    if File.file?(out_file)
      next if File.size(out_file) > File.size(inp_file)
      File.delete(out_file)
    end

    puts "#{inp_file} => #{out_file}"

    File.rename(inp_file, out_file)
  end
rescue ex
  puts ex
end
