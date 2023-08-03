require "../_data/_data"
require "../zdeps/data/btitle"

OUT_DB = ZD::Btitle.db

SELECT_STMT = "select id, zname, vname, hname from btitles where id >= $1 and id <= $2"

record Btitle, id : Int32, zname : String, vname : String, hname : String do
  include DB::Serializable
end

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  inputs = PGDB.query_all SELECT_STMT, lower, upper, as: Btitle
  puts "- block: #{block}, books: #{inputs.size}"

  break if inputs.empty?

  OUT_DB.exec "begin"

  inputs.each do |input|
    entry = ZD::Btitle.new(input.zname)

    entry.name_hv = input.hname
    entry.name_mt = input.vname

    entry.wb_id = input.id

    entry.rtime = Time.utc.to_unix
    entry._flag = 0

    entry.upsert!(OUT_DB)
  end

  OUT_DB.exec "commit"
end
