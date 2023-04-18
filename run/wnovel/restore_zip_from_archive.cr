# require "colorize"
# DIR = "/media/nipin/Vault/Asset/chivi_db/chtexts"
# OUT = "var/chaps/texts"

# def get_zip_list(sname : String)
#   files = Dir.glob("#{DIR}/#{sname}/**/*.zip")
#   puts "#{sname}, #{files.size}"

#   File.open("var/chaps/vault/#{sname}.txt", "w") do |io|
#     files.each do |file|
#       io.puts file.sub(DIR, "")
#     end
#   end
# end

# def restore(sname : String)
#   files = File.read_lines("var/chaps/vault/#{sname}.txt")

#   size = 0_i64

#   files.each_with_index(1) do |file, idx|
#     out_file = OUT + file
#     if File.file?(out_file)
#       # puts "- #{idx}/#{files.size}: #{out_file}".colorize.light_gray
#     else
#       File.copy(DIR + file, out_file)
#       size += File.size(out_file)
#       puts "- #{idx}/#{files.size}: #{out_file} (copied: #{size.humanize})".colorize.green
#     end

#     if size > 8_000_000_000
#       puts "stopping to reduce stress to the outer device"
#       exit 0
#     end
#   end
# end

# # get_zip_list("biqu5200")

# ARGV.each { |sname| restore(sname) }
