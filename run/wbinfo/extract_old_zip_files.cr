require "compress/zip"
require "colorize"

def extract_zip(zip_path : String, skip_existing = true)
  entries = {} of String => Array(String)

  out_dir = File.dirname(zip_path).sub("/www/chivi/cwd", "var/texts/rgbks")
  puts "- extract #{zip_path} to #{out_dir}"

  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.each do |entry|
      sc_id, _, cpart = entry.filename.sub(".txt", "").partition('-')

      parts = entries[sc_id] ||= [] of String
      parts << cpart
    end

    entries.each do |sc_id, parts|
      out_path = File.join(out_dir, "#{sc_id}.gbk")
      # TODO: check for empty files
      next if skip_existing && File.file?(out_path)

      puts "saving file #{out_path}".colorize.yellow

      ztext = zip["#{sc_id}-0.txt"].open(&.gets_to_end)
      ztext = ztext.sub('\n', "\n\n") # seperate title with body
      parts.sort!(&.to_i).shift

      parts.each do |cpart|
        ptext = zip["#{sc_id}-#{cpart}.txt"].open(&.gets_to_end)
        ztext += ptext.sub(/^.+\n/, "\n\n")
      end

      begin
        File.write(out_path, ztext.encode("GB18030"), encoding: "GB18030")
      rescue ArgumentError
        File.write(out_path.sub(".gbk", ".txt"), ztext)
      end
    end
  end
end

extract_zip "/www/chivi/cwd/!zxcs.me/9981/0.zip"

# INP = "/www/chivi/cwd"
# dirs = Dir.glob("#{INP}/*/")

# dirs.each do |dir|
#   files = Dir.glob("#{dir}*/*.zip")

#   files.each do |file|
#     extract_zip(file)
#     move_to = file.sub(INP, "/2tb/tmp.chivi/old-zip-texts")
#     Dir.mkdir_p(File.dirname(move_to))
#     File.copy(file, move_to)
#     File.delete(file)
#   rescue err
#     puts err
#   end
# end
