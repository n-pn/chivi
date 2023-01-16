require "db"
require "pg"
require "../../config"

db = DB.open(CV::Config.database_url)
at_exit { db.close }

file = File.open("var/fixed/dicts.tsv", "w")
at_exit { file.close }

db.query_each "select id, bhash from nvinfos where id > 0 order by id asc" do |rs|
  id, bhash = rs.read(Int64, String)
  file.puts "#{id}\t-#{bhash}"
end
