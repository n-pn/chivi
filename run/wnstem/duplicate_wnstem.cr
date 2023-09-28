ENV["CV_ENV"] = "production"

require "../../src/_data/_data"

struct Wnstem
  include DB::Serializable
  getter wn_id : Int32
  getter chmax : Int32
  getter mtime : Int64
  getter created_at : Time
  getter updated_at : Time
end

input = PGDB.query_all "select wn_id, chap_total as chmax, mtime, created_at, updated_at from wnseeds where wn_id >= 0 and sname = '~avail'", as: Wnstem

puts input.size

PGDB.transaction do |tx|
  cnn = tx.connection
  cnn.exec "delete from wnseeds where sname = '~draft' and chap_total = 0"
  cnn.exec "delete from wnseeds where sname = ''"

  sql = <<-SQL
    insert into wnseeds (wn_id, sname, s_bid, privi, chap_total, mtime, created_at, updated_at)
    values ($1, '~draft', $2, 1, $3, $4, $5, $6)
    on conflict do nothing
    SQL

  input.each do |wstem|
    total = wstem.chmax
    total = 100 if total > 100
    cnn.exec sql, wstem.wn_id, wstem.wn_id.to_s, total, wstem.mtime, wstem.created_at, wstem.updated_at
  end
end
