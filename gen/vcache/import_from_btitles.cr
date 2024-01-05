ENV["CV_ENV"] = "production"
require "../../src/_data/wnovel/btitle"
require "../../src/mt_sp/data/v_cache"

inputs = CV::Btitle.get_all
puts "total: #{inputs.size}"

mtime = TimeUtil.cv_mtime Time.local(2024, 1, 1)

inputs.each_slice(200).with_index do |slice, index|
  slice.select!(&.bt_zh.matches?(/\p{Han}/))
  Log.info { "#{index}: #{slice.size} entries" }

  items = [] of SP::VCache

  slice.each do |inp|
    raw = CharUtil.to_canon(inp.bt_zh, true)
    rid = SP::VCache.gen_rid(raw)

    items << SP::VCache.new(rid, :ztext, raw, mcv: 0)
    items << SP::VCache.new(rid, :vi_qt, inp.vi_qt, mcv: 0) unless inp.vi_qt.blank?
    items << SP::VCache.new(rid, :vi_uc, inp.vi_uc, mcv: 0) unless inp.vi_uc.blank?

    items << SP::VCache.new(rid, :ms_zv, inp.vi_ms, mcv: 0) unless inp.vi_ms.blank?
    items << SP::VCache.new(rid, :gg_zv, inp.vi_gg, mcv: 0) unless inp.vi_gg.blank?
    items << SP::VCache.new(rid, :bd_zv, inp.vi_bd, mcv: mtime) unless inp.vi_gg.blank?

    items << SP::VCache.new(rid, :ms_ze, inp.en_ms, mcv: 0) unless inp.en_ms.blank?
    items << SP::VCache.new(rid, :gg_ze, inp.en_gg, mcv: 0) unless inp.en_gg.blank?
    items << SP::VCache.new(rid, :bd_ze, inp.en_bd, mcv: 0) unless inp.en_bd.blank?
    items << SP::VCache.new(rid, :dl_ze, inp.en_dl, mcv: 0) unless inp.en_dl.blank?
  end

  ZR_DB.transaction do |tx|
    items.each(&.upsert!(db: tx.connection))
  end

  Log.info { "\t#{items.size} cached!" }
end
