# INP = "var/chaps/texts"
# OUT = "/media/nipin/Roams/Chivi/texts"

# def move_seed(sname : String)
#   out_dir = "#{OUT}/#{sname}"
#   puts "output: #{out_dir}"

#   s_bids = Dir.children("#{INP}/#{sname}")

#   s_bids.each do |s_bid|
#     files = Dir.glob("#{INP}/#{sname}/#{s_bid}/*.zip")
#     next if files.empty?

#     out_dir = "#{OUT}/#{sname}/#{s_bid}"
#     Dir.mkdir_p(out_dir)

#     files.each_with_index(1) do |file, idx|
#       next unless File.file?(file + ".unzipped")

#       out_file = "#{out_dir}/#{File.basename(file)}"
#       puts "- #{idx}/#{files.size}: #{file} => #{out_file}"

#       File.copy(file, out_file) unless File.file?(out_file)
#       File.delete(file)
#     end
#   rescue err
#     puts err
#   end
# end

# snames = ARGV
# snames = Dir.children("#{INP}") if snames.empty?

# snames.each do |sname|
#   move_seed(sname) unless sname[0].in?('.', '_', '=')
# end
