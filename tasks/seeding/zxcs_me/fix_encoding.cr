require "icu"
require "colorize"
require "file_utils"

csdet = ICU::CharsetDetector.new
files = Dir.glob("_db/_seeds/zxcs_me/texts/unrar/*.txt")
files.sort_by! { |x| File.basename(x, ".txt").to_i }

puts "[- input: #{files.size} files -]".colorize.light_cyan

files.each_with_index(1) do |inp_file, idx|
  out_file = inp_file.sub("unrar", "fixed")
  next if File.exists?(out_file)

  File.open(inp_file, "r") do |f|
    str = f.read_string(250)
    csm = csdet.detect(str)
    puts "- <#{idx}/#{files.size}> #{inp_file} encoding: #{csm.name} (#{csm.confidence})"

    f.rewind
    f.set_encoding(csm.name, invalid: :skip)
    File.write(out_file, f.gets_to_end)
  end

  del_file = inp_file.sub("unrar", "trash")
  FileUtils.mv inp_file, del_file
rescue err
  puts "- <#{idx}/#{files.size}> #{inp_file} err: #{err}".colorize.red
end
