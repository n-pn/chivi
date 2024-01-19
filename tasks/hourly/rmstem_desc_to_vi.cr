require "./yousuu_shared"

TABLE = "rmstems"

SELECT_SQL = <<-SQL
select id, intro_zh as ztext from #{TABLE}
where intro_zh <> '' and intro_vi_bd is null
limit 100
SQL

UPDATE_SQL = "update #{TABLE} set intro_vi_bd = $1 where id = $2"

char_total = 0

(1..).each do |index|
  items = PGDB.query_all(SELECT_SQL, as: Input).shuffle!
  break if items.empty?

  trans, char_total = Input.translate_batch(items, "bd_zv", index, char_total, "rmstem")

  orig_size = items.sum(&.lines.size)
  raise "size mismatch #{trans.size} #{orig_size}" if trans.size != orig_size

  start = 0
  items.each do |entry|
    count = entry.lines.size
    en_bd = trans[start, count]
    PGDB.exec UPDATE_SQL, en_bd.join('\n'), entry.id
    start += count
  end
rescue ex
  Log.warn { ex.message.colorize.yellow }
  sleep 10.seconds
end
