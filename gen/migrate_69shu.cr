require "../src/rdapp/data/czdata"

def migrate(db_path : String)
  repo = RD::Czdata.db(db_path)
  repo.open_rw(&.exec "update czdata set _user = '!69shu.pro', _note = replace(_note, '69xinshu.com', '69shu.pro')")

  old_db_path = db_path.sub("69xinshu", "69shuba")
  return unless File.file?(old_db_path)

  chmax = repo.open_ro(&.query_one "select max(ch_no) from czdata", as: Int32?) || 0

  chaps = RD::Czdata.db(old_db_path).open_ro do |db|
    query = "select * from czdata where ch_no > $1 or ztext is not null"
    db.query_all query, chmax, as: RD::Czdata
  end

  puts "#{db_path}: #{chaps.size} entries"

  chaps.each do |chap|
    chap._user = "!69shu.pro"
    chap._note = chap._note.sub("69shuba.com", "69shu.pro")
    chap.title = chap.cbody.try(&.split('\n', 2).first) || chap.title
    puts chap.title
  end

  repo.open_tx do |db|
    chaps.each(&.upsert!(db: db))
  end
end

# migrate("/2tb/zroot/wn_db/!69xinshu.com/5-zdata.db3")

Dir.glob("/2tb/zroot/wn_db/!69shuba.com/*-zdata.db3") do |db_path|
  repo = RD::Czdata.db(db_path)
  next if repo.open_ro(&.query_one "select max(ch_no) from czdata", as: Int32?)
  puts db_path
  File.delete(db_path)
end
