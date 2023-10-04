require "sqlite3"

seed_map = {} of Int32 => Hash(String, Int32)

DB.open("sqlite3:var/chaps/seed-infos.db") do |db|
  sql = "select wn_id, sname, s_bid from seeds where wn_id > 0"

  db.query_all(sql, as: {Int32, String, Int32}).group_by(&.[0]).each do |wn_id, group|
    seed_map[wn_id] = group.map { |x| {x[1], x[2]} }.to_h
  end
end

SEED_ORDER = {
  "!zxcs.me",
  "!chivi.app",
  "!hetushu.com",
  "!rengshu.com",
  "_",
  "!xbiquge.bz",
  "bxwxorg.com",
  "69shu.com",
  "biqugee.com",
  "jx.la",
}

File.each_line("var/cvmtl/corpus-books.tsv") do |line|
  next if line.empty?

  id, bslug, vname = line.split('\t')

  puts "#{id}-#{vname}"

  idx_path = "/mnt/devel/Chivi/corpus-idx/#{id}-#{bslug}.tsv"
  next if File.file?(idx_path)

  entries = [] of String

  mapped = seed_map[id.to_i]? || {"_" => id.to_i}

  snames = mapped.keys.sort_by! do |sname|
    SEED_ORDER.index(sname) || (sname[0]? == '@' ? -1 : 999)
  end

  snames.reject! { |x| x[0] == '!' && x != "!zxcs.me" }

  1.upto(384) do |ch_no|
    snames.each do |sname|
      s_bid = mapped[sname]? || id.to_i

      txt_file = "/2tb/var.chivi/_prev/ztext/#{sname}/#{s_bid}/#{ch_no}.gbk"
      next unless File.file?(txt_file)

      entries << "#{ch_no}\t#{sname}/#{s_bid}/#{ch_no}"
      break
    end
  end

  next if entries.empty?
  File.open(idx_path, "a") do |file|
    entries.each do |entry|
      file << entry << '\n'
    end
  end
end
