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
end

# winfos = PGDB.query_all "select author_zh, btitle_zh, id from wninfos", as: {String, String, Int32}
# winfos = winfos.to_h { |author, btitle, wn_id| { {author, btitle}, wn_id } }

inputs = PGDB.query_all "select sname, sn_id from rmstems where rlink = ''", as: Input
inputs = inputs.group_by { |x| x.sname }

update_sql = "update rmstems set rlink = $1 where sname = $2 and sn_id = $3"
inputs.each do |sname, rstems|
  host = Rmhost.from_name!(sname)

  PGDB.transaction do |tx|
    db = tx.connection
    rstems.each do |rstem|
      rlink = host.stem_url(rstem.sn_id)
      db.exec update_sql, rlink, rstem.sname, rstem.sn_id
      puts "#{rstem.sname}/#{rstem.sn_id} => #{rlink}"
    end
  end
end
