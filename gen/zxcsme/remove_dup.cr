require "colorize"

TEXT_DIR = "/www/chivi/xyz/seeds/zxcs.me/texts"
ORIG_DIR = "/www/chivi/xyz/seeds/zxcs.me/origs"

inp_files = Dir.glob("#{TEXT_DIR}/*.txt.old")

inp_files.each do |inp_file|
  out_file = inp_file.sub(".old", ".fix")

  if !File.file?(out_file)
    File.rename(inp_file, inp_file.sub(".old", ""))
    next
  end

  puts inp_file.colorize.yellow
  puts out_file.colorize.yellow

  # inp_data = File.read_lines(inp_file).to_set
  # out_data = File.read_lines(out_file)

  # if out_data.first(20).count(&.in?(inp_data)) > 2 # same file

  #   File.rename(inp_file, inp_file.sub(".fix", ""))
  # else # different files
  #   puts inp_file.colorize.green
  #   puts out_file.colorize.green
  #   File.delete(inp_file)
  #   File.rename(out_file, out_file.sub(".old", ""))
  # end
end
