require "../../src/mt_ai/data/zv_term"
require "../../src/mt_ai/data/mt_data"

input = DB.open "sqlite3:/2tb/app.chivi/var/mtdic/mt_sp/sino_vi.dic" do |db|
  db.query_all "select zstr from defns where length(zstr) > 1", as: String
end

query = <<-SQL
  update zvterm set d_id = 20
  where d_id = 10 and zstr = any ($1)
  SQL

MT::ZvTerm.db.exec query, args: [input]

MT::MtData.db(0).open_tx do |db|
  input.each do |zstr|
    db.exec "update mtdata set d_id = 20 where d_id = 10 and zstr = $1", zstr
  end
end
