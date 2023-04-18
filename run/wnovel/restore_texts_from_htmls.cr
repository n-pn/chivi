# require "./lib/hetushu_text"

# # PATH = "var/chaps/.html/%s/%s/%s.html.gz"

# def extract(s_bid : String)
#   files = Dir.glob("var/texts/.cache/hetushu/#{s_bid}/*.html.gz")

#   out_dir = "var/chaps/bgtexts/hetushu/#{s_bid}"
#   Dir.mkdir_p(out_dir)

#   # puts "#{out_dir}, files: #{files.size}"

#   workers = Channel({String, Int32}).new(files.size)

#   threads = 6
#   results = Channel(Nil).new(threads)

#   threads.times do
#     spawn do
#       loop do
#         file, idx = workers.receive
#         s_cid = File.basename(file, ".html.gz")

#         out_file = "#{out_dir}/#{s_cid}.gbk"

#         unless File.file?(file.sub(".html.gz", ".meta"))
#           puts "- missing meta file for #{file}"
#         end

#         if File.file?(out_file) || File.file?("#{out_dir}/#{s_cid}.txt")
#           # puts "- #{idx}/#{files.size}: #{out_file}".colorize.light_gray
#         elsif File.file?(file.sub(".html.gz", ".meta"))
#           parser = HetushuText.new(file)
#           output = parser.output
#           begin
#             File.write(out_file, output.encode("GB18030"), encoding: "GB18030")
#           rescue ArgumentError
#             File.write("#{out_dir}/#{s_cid}.txt", output)
#           end

#           puts "- #{idx}/#{files.size}: #{out_file}".colorize.green
#         end
#       rescue err
#         puts err, out_file
#       ensure
#         results.send(nil)
#       end
#     end
#   end

#   files.each_with_index(1) { |file, idx| workers.send({file, idx}) }
#   files.size.times { results.receive }
# end

# Dir.children("var/texts/.cache/hetushu").each do |s_bid|
#   extract(s_bid) unless s_bid.includes?('.')
# end
