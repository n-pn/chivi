require "colorize"
require "file_utils"

dirs = Dir.glob("var/appcv/chtexts/*/")
puts "- input: #{dirs.size} folders"

dirs.each_with_index do |dir, idx|
  files = Dir.glob("#{dir}/*.txt")

  count = 0

  files.each do |file|
    next if File.size(file) > 1000
    File.delete(file)
    count += 1
  end

  next if count == 0
  puts "- <#{idx + 1}/#{dirs.size}} #{File.basename(dir)}: #{count} files"
end
