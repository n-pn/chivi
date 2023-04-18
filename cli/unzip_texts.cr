# require "log"
# require "colorize"
# require "compress/zip"

# def log_bad_file(file_path : String)
#   log_file = File.dirname(File.dirname(file_path)) + "/bad-text.log"
#   File.open(log_file, "a", &.puts(file_path))
# end

# def combine(entries : Array(Compress::Zip::File::Entry), file_path : String)
#   entries.sort_by!(&.filename.split(/[\-\.]/)[1].to_i)

#   part0 = entries.shift.open(&.gets_to_end)
#   return unless part0.includes?('\n')

#   String.build do |io|
#     title, part0 = part0.split('\n', 2)
#     log_bad_file(file_path) if title.includes?('ǀ') || title.includes?('¦')

#     title += '\n'
#     io << title << '\n' << part0.sub(title, "")

#     entries.each do |entry|
#       io << "\n\n" << entry.open(&.gets_to_end).sub(title, "")
#     end
#   end
# end

# def extract(zip_path : String, out_path : String)
#   return false if File.file?(zip_path + ".unzipped")

#   Compress::Zip::File.open(zip_path) do |zip|
#     entries = zip.entries.group_by(&.filename.split("-").first)

#     entries.each do |s_cid, parts|
#       file = "#{out_path}/#{s_cid}.gbk"
#       next unless text = combine(parts, file)

#       File.write(file, text.encode("GB18030"), encoding: "GB18030")
#     rescue ArgumentError
#       File.write("#{out_path}/#{s_cid}.txt", text)
#     end
#   end

#   File.touch(zip_path + ".unzipped")
#   true
# rescue Compress::Deflate::Error
#   File.delete(zip_path)
# rescue Compress::Zip::Error
#   File.delete(zip_path)
# rescue ex
#   Log.error(exception: ex) { [zip_path, ex.class] }
# end

# def extract_seed(sname : String)
#   files = Dir.glob("var/chaps/texts/#{sname}/**/*.zip").sort_by! do |file|
#     s_bid = File.basename(File.dirname(file)).to_i? || 0
#     pg_no = File.basename(file, ".zip").to_i? || 0
#     {s_bid, pg_no}
#   end

#   puts [sname, files.size].colorize.cyan

#   workers = Channel({String, String, Int32}).new(files.size)

#   threads = 6
#   results = Channel(Nil).new(threads)

#   threads.times do
#     spawn do
#       loop do
#         zip_file, out_path, idx = workers.receive
#         if extract(zip_file, out_path)
#           puts " - <#{idx}/#{files.size}> [#{zip_file} => #{out_path}]"
#         end
#       rescue err
#         puts err.inspect_with_backtrace
#         puts "#{sname}, #{zip_file}, #{err.message} ".colorize.red
#       ensure
#         results.send(nil)
#       end
#     end
#   end

#   files.each_with_index(1) do |zip_file, idx|
#     out_path = File.dirname(zip_file.sub("var/chaps/texts", "var/texts/rgbks"))
#     Dir.mkdir_p(out_path)
#     workers.send({zip_file, out_path, idx})
#   end

#   files.size.times { results.receive }
# end

# snames = ARGV
# snames = Dir.children("var/chaps/texts") if snames.empty?
# puts snames.colorize.yellow

# snames.each do |sname|
#   extract_seed(sname) if sname[0] == '@'
# end
