require "colorize"
require "../../src/tsvfs/zip_store"

DIR = "_db/chdata/zh_txts"

def clean_dir(sname : String)
  root = File.join(DIR, sname)
  books = Dir.children(root)

  puts "#{seed}: #{books.size} books".colorize.cyan.bold

  books.each_with_index(1) do |snvid, idx|
    if idx % 50 == 0
      puts "- <#{idx}/#{folders.size}> [#{sname}/#{snvid}]".colorize.blue
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

Dir.children(DIR).each do |sname|
  clean_dir(sname)
end
