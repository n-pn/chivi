require "pg"
require "option_parser"

ENV["CV_ENV"] ||= "production"

require "../../cv_env"
require "../../_util/book_util"

PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

struct Input
  include DB::Serializable
  getter sname : String
  getter sn_id : String
  getter btitle_zh : String
  getter author_zh : String
end

winfos = PGDB.query_all "select author_zh, btitle_zh, id from wninfos", as: {String, String, Int32}
winfos = winfos.to_h { |author, btitle, wn_id| { {author, btitle}, wn_id } }

inputs = PGDB.query_all "select sname, sn_id, btitle_zh, author_zh from rmstems", as: Input
inputs = inputs.group_by { |x| {x.author_zh, x.btitle_zh} }

update_sql = "update rmstems set wn_id = $1 where sname = $2 and sn_id = $3"
inputs.each do |(author, btitle), rstems|
  next unless wn_id = winfos[BookUtil.fix_names(author, btitle)]?
  PGDB.transaction do |tx|
    db = tx.connection
    rstems.each do |rstem|
      db.exec update_sql, wn_id, rstem.sname, rstem.sn_id
      puts "#{rstem.sname}/#{rstem.sn_id} => #{wn_id}"
    end
  end
end
