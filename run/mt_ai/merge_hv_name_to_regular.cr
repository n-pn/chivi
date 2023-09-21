ENV["MT_DIR"] = "/2tb/app.chivi/var/mt_db/mt_ai"

require "../../src/mt_ai/data/vi_term"
require "../../src/mt_ai/core/qt_core"

cf_zstrs = File.read_lines("var/mtdic/cvmtl/vocab/chinese-family-names-2.txt").to_set
cf_zstrs.concat File.read_lines("/2tb/var.chivi/mtdic/cvmtl/vocab/chinese-family-names.tsv").map(&.split('\t').first)

hv_names = MT::ViTerm.get_all(db: MT::ViTerm.db("hv_name"))
hv_zstrs = hv_names.map(&.zstr).to_set
hv_names.select!(&.zstr.in?(cf_zstrs))

puts [cf_zstrs.size, hv_zstrs.size, hv_names.size]

MT::ViTerm.db("regular").open_ro do |db|
  query = "select * from terms where ipos = #{MT::MtEpos::NR.value} and zstr = $1"

  hv_names.each do |hv_name|
    hv_name.cpos = MT::MtEpos::NF
    hv_name.attr = MT::MtAttr[Nper, Prfx]

    next if !(existed = db.query_one?(query, hv_name.zstr, as: MT::ViTerm))
    hv_name.attr = MT::MtAttr.new(hv_name.iatt) | MT::MtAttr.new(existed.iatt)

    if !hv_name.uname.empty? || existed.uname.empty? || existed.uname.starts_with?('!')
      hv_name.plock = 2
    else
      hv_name.uname = existed.uname
      hv_name.mtime = existed.mtime
      hv_name.plock = existed.plock
    end
  end
end

MT::ViTerm.db("regular").open_tx do |db|
  hv_names.each(&.upsert!(db: db))
end

cf_zstrs = cf_zstrs.reject(&.in?(hv_zstrs))
puts cf_zstrs.size

cf_terms = cf_zstrs.map do |zstr|
  MT::ViTerm.new(
    zstr: zstr,
    cpos: "NF",
    vstr: MT::QtCore.tl_hvname(zstr),
    attr: MT::MtAttr[Nper, Prfx].to_str,
    plock: 1,
  )
end

MT::ViTerm.db("regular").open_tx do |db|
  cf_terms.each(&.upsert!(db: db))
end
