require "../src/_data/zr_db"
require "../src/mt_sp/data/v_cache_2"

enum Kind : Int16
  Ztext = 0 # original text
  Py_tm = 1 # pinyin with tone marks
  Hviet = 2 # hanviet
  Hname = 4 # name

  Vi_lv = 10 # translation from lacviet
  Vi_vp = 11 # translation from vietphrase dicts

  Qt_v1 = 14 # translated by old translator
  Mtl_0 = 15 # translated by new translator
  Mtl_1 = 16 # translated by new translator
  Mtl_2 = 17 # translated by new translator
  Mtl_3 = 18 # translated by new translator
  Mtl_4 = 19 # translated by new translator

  Vi_uc = 20 # chivi user submitted content

  Ms_zv = 30 # translated by bing from zh to vi
  Gg_zv = 31 # translated by google from zh to vi
  Bd_zv = 32 # translated by baidu from zh to vi
  C_gpt = 33 # translated by custom gpt model

  Ms_ze = 50 # translated by bing from zh to en
  Gg_ze = 51 # translated by google from zh to en
  Bd_ze = 52 # translated by baidu from zh to en
  Dl_ze = 53 # translated by deepl from zh to en

  Ms_je = 70 # translated by bing from ja to en
  Gg_je = 71 # translated by google from ja to en
  Bd_je = 72 # translated by baidu from ja to en
  Dl_je = 73 # translated by deepl from ja to en

end

MTIME = TimeUtil.cv_mtime(Time.local(2024, 3, 23, 0, 0, 0))

query = "select obj, rid, val, mcv from vcache where mcv >= $1 order by mcv asc"
items = {} of Int16 => Array(SP::VCache2)

ZR_DB.query_each query, MTIME do |rs|
  hash = items[rs.read(Int16)] ||= [] of SP::VCache2
  hash << SP::VCache2.new(rs.read(Int64), rs.read(String), rs.read(Int32))
end

# TODO: add ztexts

puts "total: #{items.sum(&.size)}"

items.each do |type, list|
  type = Kind.from_value(type).to_s.downcase
  SP::VCache2.db(type).open_tx { |db| list.each(&.upsert!(db: db)) }
  puts "[#{type}] #{list.size} saved"
end
