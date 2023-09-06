require "../../src/mt_v1/data/v1_dict"
require "../../src/mt_v1/data/v1_defn"

dict_ids = M1::ViDict.repo.open_db(&.query_all "select id from dicts", as: Int32)

output = [] of Array(DB::Any)
M1::DbDefn.repo.open_db do |db|
  dict_ids.each do |dic|
    total = db.query_one("select count (*) from defns where dic = ?", dic, as: Int32)
    next if total == 0

    avail = db.query_one("select count (*) from defns where dic = ? and _flag >= 0 ", dic, as: Int32)

    mains = db.query_one("select count (*) from defns where dic = ? and tab = 1", dic, as: Int32)
    temps = db.query_one("select count (*) from defns where dic = ? and tab = 2", dic, as: Int32)
    users = db.query_one("select count (*) from defns where dic = ? and tab = 3", dic, as: Int32)

    mtime = db.query_one?("select mtime from defns where dic = ? order by mtime desc limit 1", dic, as: Int64) || 0_i64

    unames = db.query_all("select distinct(uname) from defns where dic = ? order by id", dic, as: String)

    output << [total, avail, mains, temps, users, unames.join(","), mtime, dic] of DB::Any
  end
end

M1::ViDict.repo.open_tx do |db|
  query = <<-SQL
    update dicts set
      term_total = ?, term_avail = ?,
      main_terms = ?, temp_terms = ?, user_terms = ?,
      users = ?, mtime = ?
      where id = ?
    SQL

  output.each do |args|
    puts args
    db.exec query, args: args
  end
end
