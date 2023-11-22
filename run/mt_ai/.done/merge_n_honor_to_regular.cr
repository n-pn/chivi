# ENV["MT_DIR"] = "/2tb/app.chivi/var/mt_db/mt_ai"

require "../../src/mt_ai/data/vi_term"
require "../../src/mt_ai/core/qt_core"

nh_lines = File.read_lines("var/mtdic/honors.tsv").reject!(&.blank?)

n_honors = nh_lines.map do |line|
  zstr, vstr = line.split('\t')
  attr = MT::MtAttr[Sufx, Nper]

  attr |= :at_h if vstr.ends_with?('?')

  MT::ViTerm.new(
    zstr: zstr,
    vstr: vstr.sub("?", "").strip,
    cpos: "NH",
    attr: attr
  )
end

puts n_honors

MT::ViTerm.db("regular").open_tx do |db|
  n_honors.each(&.upsert!(db: db))
end
