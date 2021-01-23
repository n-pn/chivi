require "colorize"
require "../../src/mapper/zip_store"

DIR = "_db/chdata/zhtexts"

seeds = Dir.children(DIR).each do |seed|
  folders = Dir.glob("#{DIR}/#{seed}/*/")

  puts "#{seed}: #{folders.size} folders".colorize.cyan.bold

  folders.each_with_index(1) do |folder, idx|
    if idx % 50 == 0
      puts "- <#{idx}/#{folders.size}> #{folder}".colorize.blue
    end

    folder = folder.sub(/\/$/, "") # remove trailing `/`
    zip_store = CV::ZipStore.new("#{folder}.zip", folder)

    Dir.glob("#{folder}/*.txt").each do |file|
      next unless File.size(file) < 10

      File.delete(file)
      puts "-- <#{file}> deleted".colorize.light_red
    end

    zip_store.compress!(:archive)
  end
end
