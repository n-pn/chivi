require "../../zroot/tubook"

require "../../_data/wnovel/wninfo"
require "../../_data/wnovel/wnlink"
require "../../mt_v1/data/v1_dict"

SELECT_SQL = ZR::Tubook.schema.select_stmt { |stmt| stmt << " where id >= $1 and id <= $2" }

total = 388508
pages = total // 1000 + 1

pages.times do |block|
  lower = block &* 1000
  upper = lower &+ 999

  inputs = ZR::Tubook.open_db(&.query_all SELECT_SQL, lower, upper, as: ZR::Tubook)

  puts "- block: #{block} , books: #{inputs.size}"
  next if inputs.empty?

  PGDB.exec "begin"

  outputs = inputs.map do |input|
    wninfo = input.upsert_wninfo!
    # CV::Wnlink.upsert!(wninfo.id, "https://www.tuishujun.com/book/#{input.id}")
    # CV::Wnlink.upsert!(wninfo.id, input.origin)
    {input.id, wninfo.id, wninfo.bslug, wninfo.btitle_vi}
  end

  PGDB.exec "commit"

  M1::ViDict.open_tx do |db|
    outputs.each do |_yb_id, wn_id, bslug, vname|
      M1::ViDict.upsert_wn_dict(db, wn_id, bslug, vname) rescue nil
    end
  end

  ZR::Tubook.open_tx do |db|
    outputs.each do |tn_id, wn_id, _bslug, _vname|
      db.exec("update tubooks set wn_id = $1 where id = $2", wn_id, tn_id) rescue nil
    end
  end
end
