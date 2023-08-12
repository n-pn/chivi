# require "../ysapp/data/ysbook_data"
require "../zroot/ysbook"

require "../_data/wnovel/wninfo"
require "../_data/wnovel/wnlink"
require "../mt_v1/data/v1_dict"

SELECT_SQL = ZR::Ysbook.schema.select_stmt { |stmt| stmt << "where id >= $1 and id <= $2" }

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  inputs = ZR::Ysbook.db.query_all(SELECT_SQL, lower, upper, as: ZR::Ysbook)

  puts "- block: #{block}, books: #{inputs.size}"
  break if inputs.empty?

  PGDB.exec "begin"

  outputs = inputs.map do |input|
    wninfo = input.upsert_wninfo!
    CV::Wnlink.upsert!(wninfo.id, "https://www.yousuu.com/book/#{input.id}")
    CV::Wnlink.upsert!(wninfo.id, input.origin)
    {input.id, wninfo.id, wninfo.bslug, wninfo.btitle_vi}
  end

  PGDB.exec "commit"

  M1::DbDict.db.open_tx do |db|
    outputs.each do |_yb_id, wn_id, bslug, vname|
      M1::DbDict.init_wn_dict!(wn_id, bslug, vname, db: db) rescue nil
    end
  end

  ZR::Ysbook.db.open_tx do |db|
    outputs.each do |yn_id, wn_id, _bslug, _vname|
      db.exec("update ysbooks set wn_id = $1 where id = $2", wn_id, yn_id) rescue nil
    end
  end
end
