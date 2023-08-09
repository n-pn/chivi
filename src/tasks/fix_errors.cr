require "../_data/_data"
require "../_util/book_util"
require "../zroot/ysbook"

inputs = [] of {String, String}

ZR::Ysbook.open_db do |db|
  db.query_each("select author, btitle from ysbooks") do |rs|
    author, btitle = rs.read(String, String)
    inputs << BookUtil.fix_names(author, btitle)
  end
end

# PGDB.exec "begin"

inputs.each do |author, btitle|
  next if author == btitle
  # stmt = "select id, bslug, btitle_vi from wninfos where id > 200000 and author_zh = $1 and btitle_zh = $2"
  # result = PGDB.query_one? stmt, btitle, author, as: {Int32, String, String}
  # puts(result, "#{author} -- #{btitle}") if result

  stmt = "delete from wninfos where id > 140000 and author_zh = $1 and btitle_zh = $2 returning id, btitle_vi"
  result = PGDB.query_one? stmt, btitle, author, as: Int32
  puts(result) if result
end

# PGDB.exec "commit"
