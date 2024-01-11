require "./shared"

TABLE = "yscrits"

SELECT_SQL = <<-SQL
select id, ztext from #{TABLE}
where ztext <> '' and en_bd is null
limit 200
SQL

UPDATE_SQL = "update #{TABLE} set en_bd = $1 where id = $2"
CACHE_DIR  = "/2tb/zroot/ydata/yscrit"

char_total = 0
crit_count = 0

(1..).each do |index|
  crits = PGDB.query_all(SELECT_SQL, as: Input).shuffle!
  break if crits.empty?
  crit_count += crits.size

  trans, char_total = Input.translate_batch(crits, "bd_ze", index, char_total, "yscrit")

  orig_size = crits.sum(&.lines.size)
  raise "size mismatch #{trans.size} #{orig_size}" if trans.size != orig_size

  start = 0
  crits.each do |ycrit|
    count = ycrit.lines.size
    en_bd = trans[start, count]
    PGDB.exec UPDATE_SQL, en_bd.join('\n'), ycrit.id
    start += count
  end
rescue ex
  Log.warn { ex.message.colorize.yellow }
  sleep 10.seconds
end
