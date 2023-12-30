require "colorize"
require "compress/zip"
require "../../src/rdapp/data/czdata"

INP = "/www/var.chivi/zroot/rawtxt"

MAPPING_SQL = <<-SQL
select s_cid, ch_no from czdata where s_cid > 0
SQL

EXISTED_SQL = <<-SQL
select ch_no from czdata where ztext <> ''
SQL

UPSERT_SQL = <<-SQL
insert into czdata(ch_no, s_cid, ztext, mtime)
values ($1, $2, $3, $4)
on conflict(ch_no) do update set
  s_cid = excluded.s_cid,
  ztext = excluded.ztext,
  mtime = excluded.mtime
SQL

snames = ARGV.reject(&.starts_with?('-'))
snames = ["!69shuba.com"] if snames.empty?

snames.each do |sname|
  no_remote = sname.in? "~avail", "!zxcs.me"

  zip_paths = Dir.glob("#{INP}/#{sname}/*.zip")
  zip_paths.each do |zip_path|
    sn_id = File.basename(zip_path, ".zip")

    ch_db = RD::Czdata.db(sname, sn_id)

    known = ch_db.open_ro(&.query_all MAPPING_SQL, as: {Int32, Int32}).to_h
    skips = ch_db.open_ro(&.query_all EXISTED_SQL, as: Int32).to_set

    items, total, valid = extract_zip(zip_path, known, skips, no_remote)
    next puts "#{sname}/#{sn_id}: total #{total}, valid #{valid}, all skipped".colorize(total > valid ? :cyan : :blue) if items.empty?

    ch_db.open_tx do |db|
      items.each do |ch_no, s_cid, ztext, mtime|
        db.exec UPSERT_SQL, ch_no, s_cid, ztext, mtime
      end
    end

    puts "#{sname}/#{sn_id}: #{items.size} recovered".colorize.green
  rescue ex
    puts "#{sname}/#{sn_id}: #{ex}".colorize.red
  end
end

def extract_zip(zip_path, known, skips, no_remote)
  Compress::Zip::File.open(zip_path) do |zip|
    valid = 0

    items = zip.entries.compact_map do |entry|
      if entry.filename.ends_with?(".gbk")
        encoding = "GB18030"
        s_cid = File.basename(entry.filename, ".gbk").to_i
      else
        s_cid = File.basename(entry.filename, ".txt").to_i
      end

      next unless ch_no = no_remote ? s_cid : known[s_cid]?
      valid += 1

      next if skips.includes?(ch_no)

      ztext = entry.open do |io|
        io.set_encoding(encoding, invalid: :skip) if encoding
        io.gets_to_end
      end

      next if ztext.empty?
      {ch_no, s_cid, ztext, entry.time.to_unix}
    rescue ex
      nil
    end

    {items, zip.entries.size, valid}
  end
end
