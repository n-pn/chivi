require "sqlite3"

map_name = {} of Int32 => String

File.each_line("var/cvmtl/corpus-books.tsv") do |line|
  rows = line.split('\t')
  map_name[rows[0].to_i] = "#{rows[0]}-#{rows[1]}" if rows.size > 1
end

DB.open("sqlite3:var/chaps/seed-infos.db") do |db|
  sql = "select wn_id, s_bid from seeds where wn_id > 0 and sname = '!zxcs.me' order by s_bid asc"

  db.query_each(sql) do |rs|
    wn_id, s_bid = rs.read(Int32, Int32)

    inp_dir = "var/anlzs/texsmart/!zxcs.me-#{s_bid}"
    out_dir = "var/anlzs/texsmart/#{map_name[wn_id]}"
    next unless File.exists?(inp_dir)

    puts "#{inp_dir} => #{out_dir}"
    File.rename(inp_dir, out_dir)
  end
end
