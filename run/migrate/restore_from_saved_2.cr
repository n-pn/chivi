require "compress/zip"
require "../../src/rdapp/data/czdata"

INP = "/2tb/var.chivi/zroot/wntext"
OUT = "/2tb/zroot/ztext"

SAVE_SQL = <<-SQL
insert into czdata(ch_no, s_cid, ztext, mtime)
values ($1, $2, $3, $4)
on conflict (ch_no) do update set
  s_cid = excluded.s_cid,
  ztext = excluded.ztext,
  mtime = excluded.mtime
SQL

snames = ARGV.reject(&.starts_with?('-'))
snames = ["~avail"] if snames.empty?

snames.each do |sname|
  children = Dir.children("#{INP}/#{sname}")
  children.each do |sn_id|
    data = Dir.glob("#{INP}/#{sname}/#{sn_id}/*.txt").map do |fpath|
      s_cid, _cksum, ch_no, _ext = File.basename(fpath).split(/[-.]/)

      RD::Czdata.new(
        ch_no: ch_no.to_i,
        s_cid: s_cid.to_i,
        ztext: File.read(fpath),
        mtime: File.info(fpath).modification_time.to_unix,
      )
    end

    next if data.empty?

    RD::Czdata.db(sname, sn_id).open_tx do |db|
      data.each { |item| db.exec SAVE_SQL, item.ch_no, item.s_cid, item.ztext, item.mtime }
    end

    puts "#{sname}/#{sn_id}: #{data.size} files copied"
  end
end
