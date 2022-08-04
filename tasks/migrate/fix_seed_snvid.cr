require "../shared/bootstrap"

def load_map(path : String | Path)
  File.read_lines(path).each_with_object({} of String => String) do |line, hash|
    cols = line.split('\t')
    next if cols.size < 3
    hash[cols[0]] = cols[1]
  end
end

TEXT_DIR = Path["var", "chtexts"]
SEED_DIR = Path["var", "chaps", "users"]

NAME_MAP = load_map Path["var", "fixed", "books.tsv"]

def rename_snvids(sname : String)
  CV::Chroot.query.where("sname = ?", sname).each do |chroot|
    old_snvid = chroot.snvid

    next unless new_snvid = NAME_MAP[old_snvid]?
    next if new_snvid == old_snvid

    puts "- #{old_snvid} => #{new_snvid}".colorize.green

    chroot.snvid = new_snvid
    chroot.save!
  end
end

def rename_text_dirs(sname : String)
  text_dir = TEXT_DIR.join(sname)
  return unless File.exists?(text_dir)

  Dir.children(text_dir).each do |old_snvid|
    next unless new_snvid = NAME_MAP[old_snvid]?

    old_path = text_dir.join(old_snvid)
    new_path = text_dir.join(new_snvid)

    puts "-- #{old_path} => #{new_path}".colorize.blue
    File.rename(old_path, new_path)
  end
end

def rename_seed_dirs(sname : String)
  seed_dir = SEED_DIR.join(sname)
  return unless File.exists?(seed_dir)

  Dir.children(seed_dir).each do |old_snvid|
    next unless new_snvid = NAME_MAP[old_snvid]?

    old_path = seed_dir.join(old_snvid)
    new_path = seed_dir.join(new_snvid)

    puts "-- #{old_path} => #{new_path}".colorize.yellow
    File.rename(old_path, new_path)
  end
end

ARGV.each do |sname|
  rename_text_dirs(sname)
  rename_seed_dirs(sname)
  rename_snvids(sname)
end
