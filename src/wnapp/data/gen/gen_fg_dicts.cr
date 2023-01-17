require "pg"
require "../../../cv_env"

db = DB.open(CV_ENV.database_url)
at_exit { db.close }

file = File.open("var/fixed/dicts.tsv", "w")
at_exit { file.close }

db.query_each "select id, bhash from nvinfos where id > 0 order by id asc" do |rs|
  id, bhash = rs.read(Int64, String)
  file.puts "#{id}\t-#{bhash}"
end
