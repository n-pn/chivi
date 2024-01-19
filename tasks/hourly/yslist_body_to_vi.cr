require "./yousuu_shared"

TABLE = "yslists"

SELECT_SQL = <<-SQL
select id, zdesc as ztext from #{TABLE}
where zdesc <> '' and vdesc_bd is null
limit 500
SQL

UPDATE_SQL = "update #{TABLE} set vdesc_bd = $1 where id = $2"

CACHE_DIR = "/2tb/zroot/ydata/yslist"

char_total = 0
item_count = 0

(1..).each do |index|
  input = PGDB.query_all(SELECT_SQL, as: Input).shuffle!
  break if input.empty?

  trans, char_total = Input.translate_batch(input, "bd_zv", index, char_total, "yslist")

  orig_size = input.sum(&.lines.size)
  raise "size mismatch #{trans.size} #{orig_size}" if trans.size != orig_size

  start = 0
  input.each do |entry|
    count = entry.lines.size
    vi_bd = trans[start, count].join('\n')
    PGDB.exec UPDATE_SQL, vi_bd, entry.id
    start += count
  end

  item_count += input.size
  puts "- #{index}: #{item_count} resolved".colorize.blue
rescue ex
  Log.warn { ex.message.colorize.yellow }
  sleep 10.seconds
end
