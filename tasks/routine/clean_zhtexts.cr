require "colorize"
require "../../src/filedb/stores/zip_store"

DIR = "_db/nvdata/zhtexts"

seeds = Dir.children(DIR).each do |seed|
  folders = Dir.glob("#{DIR}/#{seed}/*/")

  puts "#{seed}: #{folders.size} folders".colorize.cyan.bold

  folders.each_with_index do |folder, idx|
    if idx % 100 == 99
      puts "- <#{idx + 1}/#{folders.size}> #{folder}".colorize.blue
    end

    folder = folder.sub(/\/$/, "") # remove trailing `/`
    zip_store = CV::ZipStore.new("#{folder}.zip", folder)

    Dir.glob("#{folder}/*.txt").each do |file|
      next unless File.size(file) < 5 || zip_store.archives?(File.basename(file))

      File.delete(file)
      puts "-- <#{file}> deleted".colorize.light_red
    end
  end
end
