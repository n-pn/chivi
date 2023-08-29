require "../../src/zroot/shared/chinfo"
require "../../src/wnapp/data/chinfo"

def get_chmax(db)
  query = "select ch_no from chinfos order by ch_no desc limit 1"
  db.query_one?(query, as: Int32) || 0
end

def resync(sname : String, sn_id : String, vi_db_path = WN::Chinfo.db_path(sname, sn_id))
  vi_chmax = DB.connect("sqlite3:#{vi_db_path}?immutable=1") { |db| get_chmax(db) }

  ZR::Chinfo.db(sname, sn_id).open_tx do |zh_db|
    zh_chmax = get_chmax(zh_db)
    break 0 if zh_chmax >= vi_chmax

    zh_db.exec "attach database 'file:#{vi_db_path}?immutable=1' as src"

    zh_db.exec <<-SQL, zh_chmax
      insert into chinfos(ch_no, rlink, spath, ztitle, zchdiv, cksum)
      select ch_no, rlink, spath, ztitle, zchdiv, cksum
      from src.chinfos where src.chinfos.ch_no > $1
    SQL

    vi_chmax &- zh_chmax
  end
end

def resync(sname : String)
  files = Dir.glob("var/zroot/wnchap/#{sname}/*.db3")

  files.each_with_index do |file, idx|
    sn_id = File.basename(file, ".db3")
    synced = resync(sname, sn_id, file)

    puts "- <#{idx}/#{files.size}> #{file}: #{synced} synced"
  rescue ex
    File.delete(file) if ex.message.try(&.includes?("no such table"))
  end
end

snames = ARGV.select!(&.starts_with?('!'))
snames.each { |sname| resync(sname) }
