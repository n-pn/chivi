require "colorize"
DIR = "_db/nvdata/zhtexts"

seeds = Dir.children(DIR).each do |seed|
  folders = Dir.glob("#{DIR}/#{seed}/*/")
  puts "#{seed}: #{folders.size} folders".colorize.cyan.bold

  folders.each_with_index do |folder, idx|
    if idx % 100 == 99
      puts "- <#{idx + 1}/#{folders.size}> #{folder}".colorize.blue
    end

    Dir.glob(folder + "*.txt").each do |file|
      next if File.size(file) > 5
      puts "-- Delete empty file #{file}".colorize.light_red
      File.delete(file)
    end
  end
end
