require "sqlite3"
require "../src/_util/char_util"

DB_URL = "sqlite3:/2tb/app.chivi/var/mtapp/v1dic/v1_defns.dic"

query = "select id, key from defns"
inputs = DB.open("#{DB_URL}?immutable=1", &.query_all query, as: {Int32, String})

output = [] of {Int32, String}

inputs.each do |id, zstr|
  norm = CharUtil.to_canon(zstr, upcase: true)
  output << {id, zstr} unless norm == zstr
end

puts output.size

DB.open("#{DB_URL}?synchronous=normal") do |db|
  db.exec "begin"

  output.each do |id, norm|
    db.exec "update defns set key = $1 where id = $2", norm, id
  end

  db.exec "commit"
end
