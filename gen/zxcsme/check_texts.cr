TEXT_DIR = "/www/chivi/xyz/seeds/zxcs.me/texts"

# inputs = Dir.glob("#{TEXT_DIR}/*.txt")
# inputs.each do |fpath|
#   lines = File.read_lines(fpath)
#   found = lines.select(&.includes?("$1"))
#   puts [fpath, found] unless found.empty?
# end

inputs = Dir.glob("#{TEXT_DIR}/*.db3")
OUT_DIR = "/2tb/srv.chivi/zr_db"

inputs.each do |inp_path|
  out_path = "#{OUT_DIR}/#{File.basename(inp_path)}"
  puts "#{inp_path} => #{out_path}"
  File.copy(inp_path, out_path)
  File.delete(inp_path)
end

# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/11282.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/10792.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/10356.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/10314.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/10295.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/4838.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/4490.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/2528.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/2257.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/1711.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/1588.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/1154.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/3217.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/11433.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/1978.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/1700.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/1363.db3"

# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/2165.db3"
# File.delete? "/www/chivi/xyz/seeds/zxcs.me/texts/1296.db3"
