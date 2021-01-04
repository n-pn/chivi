require "colorize"
require "../../src/filedb/stores/zip_store"

DIR = "_db/nvdata/zhtexts"

def archive(seed : String)
  seed_path = "#{DIR}/#{seed}"
  unless File.exists?(seed_path) && File.directory?(seed_path)
    return puts "#{seed} not found!".colorize.red
  end

  book_dirs = Dir.glob(File.join(seed_path, "*/")).reject { |x| Dir.empty?(x) }
  puts "\n[#{seed}] folders: #{book_dirs.size}.".colorize.cyan

  book_dirs.each_with_index do |book_dir, idx|
    book_uid = File.basename(book_dir)
    zip_name = File.join(seed_path, "#{book_uid}.zip")

    puts "- <#{idx + 1}/#{book_dirs.size}> [#{seed}/#{book_uid}.zip]".colorize.blue
    zip_file = CV::ZipStore.new(zip_name, book_dir)
    zip_file.compress!(:archive)
  rescue err
    puts err.colorize.red
    gets
  end
end

seeds = ARGV.empty? ? Dir.children(DIR) : ARGV
seeds.each do |seed|
  archive(seed)
end
