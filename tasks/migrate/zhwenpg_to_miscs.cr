require "../shared/bootstrap"

def load_map(path : String | Path)
  File.read_lines(path).each_with_object({} of String => String) do |line, hash|
    cols = line.split('\t')
    next if cols.size < 3
    hash[cols[0]] = cols[1]
  end
end

TEXT_DIR = Path["var", "chtexts"]

NAME_MAP = load_map Path["var", "fixed", "zhwenpg.tsv"]

OUT_PATH = TEXT_DIR.join("miscs")
Dir.mkdir_p(OUT_PATH)

NAME_MAP.each do |old_snvid, new_snvid|
  puts "- #{old_snvid} => #{new_snvid}".colorize.green
  `cp -r "#{TEXT_DIR.join("zhwenpg", old_snvid)}" "#{OUT_PATH.join(new_snvid)}"`
end

CV::Chroot.query.where("sname = 'zhwenpg'").each do |chroot|
  old_snvid = chroot.snvid
  next unless new_snvid = NAME_MAP[old_snvid]?

  chroot.sname = "miscs"
  chroot.snvid = new_snvid
  chroot.save!
end
