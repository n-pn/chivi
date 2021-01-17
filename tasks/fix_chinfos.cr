require "colorize"
require "file_utils"

SEEDS = "_db/chdata/chseeds"
INFOS = "_db/chdata/chinfos"

Dir.glob("#{SEEDS}/*/").each do |seed_dir|
  sname = File.basename(seed_dir)
  puts sname

  FileUtils.mkdir_p(seed_dir + "stats")

  orig_dir = seed_dir + "origs"
  FileUtils.mkdir_p(orig_dir)

  info_dir = seed_dir + "infos"
  FileUtils.mkdir_p(info_dir)

  Dir.glob("#{INFOS}/#{sname}/*/").each do |book_dir|
    puts book_dir

    orig_file = book_dir + "_seed.tsv"
    if File.exists?(orig_file)
      FileUtils.mv orig_file, "#{orig_dir}/#{File.basename(book_dir)}.tsv"
    end

    info_file = book_dir + "trans.tsv"
    if File.exists?(info_file)
      FileUtils.mv info_file, "#{info_dir}/#{File.basename(book_dir)}.tsv"
    end
  end
end
