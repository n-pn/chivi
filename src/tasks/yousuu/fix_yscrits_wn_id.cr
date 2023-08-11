ENV["CV_ENV"] = "production" if ARGV.includes?("--prod")

require "../../_data/_data"
require "../../zroot/ysbook"

stmt = "select id, wn_id from ysbooks where wn_id > 0"
inputs = ZR::Ysbook.open_db(&.query_all(stmt, as: {Int32, Int32}))

inputs.each_slice(500) do |slice|
  puts slice

  PGDB.exec "begin"

  slice.each do |yn_id, wn_id|
    PGDB.exec "update ysbooks set nvinfo_id = $1 where id = $2", wn_id, yn_id
    PGDB.exec "update yscrits set nvinfo_id = $1 where ysbook_id = $2", wn_id, yn_id
  end

  PGDB.exec "commit"
end
