require "sqlite3"

in_10_books = Set(String).new

File.each_line("var/dicts/inits/in-10-books.tsv") do |line|
  key = line.split('\t').first
  in_10_books << key
end

output = {} of String => Hash(String, Int32)

DB.open("sqlite3:var/anlzs/texsmart/out-all.db") do |db|
  db.query_each "select zstr, ztag, count from terms where type < 300 order by count desc" do |rs|
    zstr, ztag, count = rs.read(String, String, Int32)
    next unless in_10_books.includes?(zstr)

    hash = output[zstr] ||= {} of String => Int32
    hash[ztag] ||= count
  end
end

out_file = File.open("var/dicts/_temp/ctag_in_10_books.tsv", "w")
at_exit { out_file.close }

output.each do |zstr, count|
  out_file << zstr

  count.each do |ztag, occu|
    out_file << '\t' << ztag << ':' << occu
  end

  out_file << '\n'
end
