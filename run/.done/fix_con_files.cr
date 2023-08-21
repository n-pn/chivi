require "../src/wnapp/data/viuser/chtext_anlz_ulog"

struct Input
  include DB::Serializable

  getter wn_id : String

  getter ch_no : Int32
  getter p_idx : Int32 = 0

  getter uname : String = ""
  getter cksum : String = ""

  getter _algo : String = ""
  getter ctime : Int64 = Time.utc.to_unix
end

inputs = DB.open("sqlite3:var/wnapp/chtext-anlz-ulog.db?immutable=1") do |db|
  db.query_all("select * from anlz_ulogs", as: Input)
end

count = 0

inputs.group_by(&.wn_id).each do |wn_id, items|
  output = items.map do |entry|
    WN::ChtextAnlzUlog.new(
      ch_no: entry.ch_no,
      p_idx: entry.p_idx,
      uname: entry.uname,
      cksum: entry.cksum,
      _algo: entry._algo,
      mtime: entry.ctime
    )
  end

  output.uniq! { |x| {x.ch_no, x.p_idx, x.uname, x.cksum} }

  count += output.size
  puts "- #{wn_id}: #{output.size}"

  # WN::ChtextAnlzUlog.db(wn_id).open_tx do |db|
  #   output.each(&.create!(db: db))
  # end
end

puts inputs.size, count
