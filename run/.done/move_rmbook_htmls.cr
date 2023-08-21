# INP = "/www/chivi/xyz/books/.html"
# OUT = "/2tb/var.chivi/.keep/rmbook"

# require "../src/_util/zstd_util"

# def move(site : String)
#   Dir.mkdir_p("#{OUT}/#{site}")

#   files = Dir.glob("#{INP}/#{site}/*.zst")
#   files.each do |inp_file|
#     sb_id = File.basename(inp_file, ".htm.zst")

#     out_file = "#{OUT}/#{site}/#{sb_id}.htm"
#     next if File.file?(out_file)

#     out_data = ZstdUtil.read_file(inp_file)

#     utime = File.info(inp_file).modification_time
#     File.write(out_file, out_data)

#     File.utime(utime, utime, out_file)
#     File.delete(inp_file)

#     puts "#{inp_file} => #{out_file}"
#   end
# end

# sites = Dir.children(INP)
# sites.each do |site|
#   move site
# end
