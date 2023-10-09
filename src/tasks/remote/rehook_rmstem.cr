require "pg"
require "option_parser"

ENV["CV_ENV"] ||= "production"

require "../../cv_env"
require "../../_util/book_util"
require "../../rdapp/_raw/rmhost"

PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

struct Input
  include DB::Serializable
  getter sname : String
  getter sn_id : String
  getter wn_id : Int32

  getter btitle_zh : String
  getter author_zh : String
end

wn_ids = PGDB.query_all "select author_zh, btitle_zh, id from wninfos", as: {String, String, Int32}
wn_ids = wn_ids.to_h { |a, b, w| { {a, b}, w } }

inputs = PGDB.query_all "select sname, sn_id, wn_id, btitle_zh, author_zh from rmstems", as: Input
inputs = inputs.group_by { |x| {x.author_zh, x.btitle_zh} }

update_sql = "update rmstems set wn_id = $1 where sname = $2 and sn_id = $3"

inputs.each do |(author_zh, btitle_zh), rstems|
  next unless wn_id = wn_ids[BookUtil.fix_names(author_zh, btitle_zh)]?
  rstems.reject!(&.wn_id.== wn_id)
  next if rstems.empty?

  PGDB.transaction do |tx|
    db = tx.connection
    rstems.each do |rstem|
      db.exec update_sql, wn_id, rstem.sname, rstem.sn_id
      puts "#{rstem.sname}/#{rstem.sn_id}: #{rstem.wn_id} => #{wn_id}"
    end
  end
end
