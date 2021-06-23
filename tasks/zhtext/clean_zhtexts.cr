require "colorize"
require "../../src/tabkv/zip_store"

DIR = "_db/chdata/zh_txts"

def clean_dir(zseed : String)
  root = File.join(DIR, zseed)
  books = Dir.children(root)

  puts "#{seed}: #{books.size} books".colorize.cyan.bold

  books.each_with_index(1) do |snvid, idx|
    if idx % 50 == 0
      puts "- <#{idx}/#{folders.size}> [#{zseed}/#{snvid}]".colorize.blue
    end

    txt_dir = File.join(root, snvid)
    next unless File.directory?(txt_dir)

    Dir.glob("#{txt_dir}/*.txt").each do |file|
      next if File.size(file) > 5
      File.delete(file)
      puts "-- <#{file}> deleted".colorize.light_red
    end

    zip_file = txt_dir.sub("zh_txts", "zh_zips") + ".zip"
    CV::ZipStore.new(zip_file, txt_dir).compress!(:archive)
  end
end

Dir.children(DIR).each do |zseed|
  clean_dir(zseed)
end
