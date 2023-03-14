require "compress/zip"

INP = "var/ysapp/repls"

OUT = "var/ysapp/repls-txt"

# Dir.glob("#{INP}/*-vi").each do |dir|
#   Dir.glob("#{dir}/*.zip") do |zip_path|
#     Compress::Zip::File.open(zip_path) do |zip|
#       zip.entries.each do |entry|
#         out_file = "#{OUT}/#{entry.filename[0..3]}-vi/#{entry.filename}"
#         next if File.file?(out_file)
#         Dir.mkdir_p(File.dirname(out_file))
#         puts "#{entry.filename} => #{out_file}"

#         content = entry.open(&.gets_to_end)
#         File.write(out_file, content)
#       end
#     end
#   end
# end

Dir.glob("#{OUT}/*-vi").each do |dir|
  Dir.glob("#{dir}/*..htm") do |htm_path|
    puts htm_path
    out_path = htm_path.sub("..htm", ".htm")

    if File.file?(out_path)
      File.delete(htm_path)
    else
      File.rename(htm_path, out_path)
    end
  end
end
