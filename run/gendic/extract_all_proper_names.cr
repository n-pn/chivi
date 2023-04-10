require "sqlite3"

out_file = File.open("var/dicts/_temp/all-proper.tsv", "w")
at_exit { out_file.close }

DB.open("sqlite3:var/anlzs/texsmart/out-all.db") do |db|
  db.query_each "select zstr, count from terms where ztag = 'NR' and count > 10 order by count desc" do |rs|
    out_file << rs.read(String) << '\t' << rs.read(Int32) << '\n'
  end
end
