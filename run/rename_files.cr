STEM_DIR = "/2tb/var.chivi/rm_db/stems"
TEXT_DIR = "/2tb/var.chivi/rm_db/texts"

STEM_OUT = "/2tb/var.chivi/stems"
TEXT_OUT = "/2tb/var.chivi/texts"

Dir.each_child(TEXT_OUT) do |sname|
  Dir.each_child("#{TEXT_OUT}/#{sname}") do |sn_id|
    files = Dir.glob("#{TEXT_OUT}/#{sname}/#{sn_id}/*.bzv.txt")
    files.each do |file|
      puts file
      File.rename(file, file.sub(".bzv", ".bt_zv"))
    end
  end
end

# INP = "/2tb/var.chivi/texts"
# OUT = "/2tb/var.chivi/stems"

# INP = "/2tb/var.chivi/stems"
# # OUT = "/2tb/var.chivi/texts"

# Dir.each_child(INP) do |sname|
#   # next unless child[0] == '!'

#   s_dir = "#{INP}/#{sname}"
#   next unless File.directory?(s_dir)

#   puts s_dir

#   inp_files = Dir.glob("#{s_dir}/*.db3")

#   inp_files.each do |inp_file|
#     next if inp_file.ends_with?("cinfo.db3")
#     out_file = inp_file.sub(".db3", "-cinfo.db3")

#     puts out_file
#     File.rename(inp_file, out_file) # unless File.exists?(out_file)

#   rescue ex
#     puts ex
#   end

#   # File.rename("#{TEXT_DIR}/#{child}", "#{TEXT_OUT}/rm#{child}")
# end
