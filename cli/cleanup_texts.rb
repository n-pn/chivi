require "json"
require "fileutils"

INP = "var/appcv/chtexts"
inps = Dir.glob("#{INP}/*/")

inps.each do |inp_dir|

  files = Dir.children(inp_dir)
  # puts "#{inp_dir}: #{files.size} files"

  files.each do |file|
    path = File.join(inp_dir, file)
    next if File.size(path) > 0

    puts file
    File.delete(path)
  end
end
