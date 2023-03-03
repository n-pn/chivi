require "../src/ysapp/_raw/raw_ys_crit"
MAP = {} of String => {String, String}

def add_json_file(file : String)
  puts file

  json = File.read(file)
  return unless json.starts_with?('{')

  crits, _ = YS::RawYsCrit.from_book_json(json)

  crits.each do |crit|
    MAP[crit.uuid] ||= {crit.user._id.to_s, crit.user.name}
  end
rescue ex
  puts ex
end

def add_old_tsv(file : String)
  puts file

  File.each_line(file) do |line|
    cols = line.split('\t')
    next unless cols.size > 3
    y_cid = cols[0]
    y_uid = cols[2]
    uname = cols[3]

    MAP[y_cid] ||= {y_uid, uname}
  end
end

files = Dir.glob("var/ysraw/crits-by-book/**/*.json")
files.each { |file| add_json_file(file) }

files = Dir.glob("var/ysraw/archive/yscrits/*-infos.tsv")
files.each { |file| add_old_tsv(file) }

files = Dir.glob("var/ysraw/archive/yscrits.older/*-infos.tsv")
files.each { |file| add_old_tsv(file) }

File.open("var/ysraw/crit_users.tsv", "w") do |io|
  MAP.each do |y_cid, (y_uid, zname)|
    io << y_cid << '\t' << y_uid << '\t' << zname << '\n'
  end
end
