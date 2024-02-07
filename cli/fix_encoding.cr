require "icu"
require "colorize"

CSDET = ICU::CharsetDetector.new

ARGV.each do |dir|
  Dir.glob(File.join(dir, "**/*.txt")).each do |inp_file|
    out_file = inp_file.sub(".txt", ".utf8")
    next puts "[#{out_file}] existed, skipping" if File.file?(out_file)

    File.open(inp_file, "r") do |file|
      sample = file.read_string({1024, file.size}.min)
      encoding = CSDET.detect(sample).name

      file.rewind
      file.set_encoding(encoding, invalid: :skip)
      File.write(out_file, file.gets_to_end)
      puts "[#{inp_file}] #{encoding.colorize.green} => UTF-8"
    end
  end
end
