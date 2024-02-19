ENV["CV_ENV"] = "production"

require "../src/_data/_data"

QUERY = <<-SQL
update tsrepos set chap_total = $1, chap_avail = $2, word_count = $3, scan_mtime = $4
where sname = $5 and sn_id = $6
SQL

files = Dir.glob("/2tb/zroot/*.tsv")

files.each do |fpath|
  sname = File.basename(fpath, ".tsv")
  puts sname

  input = File.read_lines(fpath).reject!(&.empty?).compact_map do |line|
    sn_id, mtime, total, avail, count = line.split('\t')
    {sn_id.to_i, mtime.to_i64, total.to_i, avail.to_i, count.to_i} if total != "0"
  rescue
    nil
  end

  input.each_slice(500) do |lines|
    puts "#{fpath}: #{lines.size}"

    PGDB.transaction do |tx|
      db = tx.connection
      lines.each do |sn_id, mtime, total, avail, count|
        db.exec QUERY, total, avail, count, mtime, sname, sn_id
      end
    end
  end
end
