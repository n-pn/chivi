require "../src/_data/wnovel/wninfo"
require "../src/upapp/data/upinfo"
require "../src/wnapp/data/wnseed"

existed = PGDB.query_all("select viuser_id, coalesce(wninfo_id, 0) from upinfos", as: {Int32, Int32}).to_set

select_query = "select * from wnseeds where sname like '@%' and chap_total > 0 order by id asc"

viusers = PGDB.query_all("select uname, id from viusers", as: {String, Int32}).to_h

record Wninfo,
  btitle_zh : String,
  btitle_hv : String,
  author_zh : String,
  author_vi : String,
  bintro : String do
  include DB::Serializable
end

wninfos = Hash(Int32, Wninfo).new do |h, k|
  query = <<-SQL
    select btitle_zh, btitle_hv, author_zh, author_vi, bintro
    from wninfos where id = $1 limit 1
    SQL
  PGDB.query_one query, k, as: Wninfo
end

inputs = PGDB.query_all select_query, as: WN::Wnstem
inputs.reject! { |x| existed.includes?({viusers[x.sname[1..]], x.wn_id}) }

outputs = inputs.map do |input|
  vbook = wninfos[input.wn_id]

  zname = "［#{vbook.author_zh}］#{vbook.btitle_zh} [wn:#{input.wn_id}]"
  vname = "[#{vbook.author_vi}] #{vbook.btitle_hv} [wn:#{input.wn_id}]"
  labels = [vbook.author_vi, "wn:#{input.wn_id}"]
  entry = UP::Upinfo.new(zname, vname, labels)

  entry.viuser_id = viusers[input.sname[1..]]
  entry.wninfo_id = input.wn_id
  entry.vintro = vbook.bintro

  entry.mtime = input.mtime

  entry.chap_count = input.chap_total
  entry.created_at = input.created_at
  entry.updated_at = input.updated_at

  entry
end

PGDB.transaction do |tx|
  outputs.each(&.upsert!(db: tx.connection))
end
