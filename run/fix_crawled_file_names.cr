require "colorize"
require "../src/_util/hash_util"

BOOK_DIR = "var/ysraw/books"
USER_DIR = "var/ysraw/users"
CRIT_DIR = "var/ysraw/crits-by-user"

def fix_dir(dir : String)
  files = Dir.glob("#{dir}/**/*.json.zst")

  files.each do |file|
    name = File.basename(file, ".json.zst")

    _, _, hash = name.partition('-')

    unless hash.empty?
      hash_2 = HashUtil.encode32(hash.to_u32)
      puts "#{hash} => #{hash_2}".colorize.yellow
      File.rename(file, file.sub("-" + hash, "." + hash_2))
      next
    end

    uuid, _, hash = name.partition('.')

    if hash.empty?
      puts " #{file} => #{uuid}.latest".colorize.green
      File.rename(file, file.sub("#{uuid}.json.zst", "#{uuid}.latest.json.zst"))
    end
  end
end

fix_dir(BOOK_DIR)
fix_dir(USER_DIR)
fix_dir(CRIT_DIR)
