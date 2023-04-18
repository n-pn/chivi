# require "colorize"
# require "compress/zip"
# require "option_parser"

# INP_DIR = "var/chaps/texts"
# OUT_DIR = "var/inits/hanlp/data/inp"

# def extract(inp_path : String)
#   puts inp_path

#   zip_file = File.join(INP_DIR, inp_path, "0.zip")
#   return unless File.exists?(zip_file)

#   out_path = File.join(OUT_DIR, inp_path)
#   Dir.mkdir_p(out_path)

#   file_count = 0

#   Compress::Zip::File.open(zip_file) do |zip|
#     zip.entries.each do |entry|
#       next unless entry.filename.ends_with?("-0.txt")
#       txt_path = File.join(out_path, entry.filename)
#       next if File.exists?(txt_path)

#       File.write(txt_path, entry.open(&.gets_to_end))
#       file_count += 1
#     end
#   end
# end

# Dir.children(INP_DIR + "/zxcs_me").each do |dir|
#   extract("zxcs_me/#{dir}")
# rescue
#   puts dir
# end
