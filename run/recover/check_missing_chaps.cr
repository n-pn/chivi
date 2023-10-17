require "../../src/rdapp/data/chinfo"
require "../../src/rdapp/data/rmstem"

CHAP_CHMAX_SQL = "select coalesce(ch_no, 0) from chinfos order by ch_no desc limit 1"
STEM_CHMAX_SQL = "select sname, sn_id, chap_count from rmstems where sname = $1"
STEM_PATCH_SQL = "update rmstems set chap_count = $1 where sname = $2 and sn_id = $3"

struct Input
  include DB::Serializable
  getter sname : String
  getter sn_id : String
  getter chap_count : Int32
end

def check(sname : String)
  inputs = PGDB.query_all STEM_CHMAX_SQL, sname, as: Input

  inputs.each do |input|
    new_db = RD::Chinfo.db("rm#{input.sname}/#{input.sn_id}")
    real_chmax = new_db.query_one(CHAP_CHMAX_SQL, as: Int32) rescue 0

    case
    when input.chap_count == real_chmax
      # puts "#{new_db.db_path}: #{real_chmax}".colorize.green
    when input.chap_count < real_chmax
      puts "#{new_db.db_path}: #{real_chmax} != #{input.chap_count}".colorize.cyan
      PGDB.exec STEM_PATCH_SQL, real_chmax, input.sname, input.sn_id
    else
      puts "#{new_db.db_path}: #{real_chmax} != #{input.chap_count}".colorize.red
    end
  end
end

check "!zxcs.me"
# check "!hetushu.com"
# check "!biqugee.com"
# check "!bxwxorg.com"
