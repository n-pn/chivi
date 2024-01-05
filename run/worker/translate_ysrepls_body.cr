require "colorize"

ENV["CV_ENV"] ||= "production"
require "../../src/_data/_data"
require "../../src/mt_sp/util/bd_tran"

TABLE = "ysrepls"

SELECT_SQL = <<-SQL
select id, ztext from #{TABLE}
where ztext <> '' and vi_bd is null
limit 1000
SQL

UPDATE_SQL = "update #{TABLE} set vi_bd = $1 where id = $2"

record Input, id : Int32, ztext : String do
  include DB::Serializable

  getter lines : Array(String) do
    @ztext.lines.compact_map do |line|
      line = line.gsub('\u003c', '<').gsub(/\p{Cc}/, "").strip
      line unless line.empty?
    end
  end
end

def split_text(crits : Array(Input))
  texts = [[] of String]

  total = 0
  limit = 4500

  crits.each do |ycrit|
    ycrit.lines.each do |zline|
      texts.last << zline
      total += zline.size

      next if total < limit

      texts << [] of String
      total = 0
    end
  end

  texts.pop if texts.last.empty?
  texts
end

char_total = 0
crit_count = 0
loop_index = 0

loop do
  input = PGDB.query_all(SELECT_SQL, as: Input)
  break if input.empty?

  input.each_slice(100) do |crits|
    loop_index += 1

    texts = split_text(crits)
    trans = [] of String

    crit_count += crits.size

    texts.each_with_index(1) do |lines, index_2|
      char_count = lines.sum(&.size) + lines.size
      char_total += char_count

      Log.info { "<#{loop_index}-#{index_2}> #{char_count} chars".colorize.cyan }
      trans.concat SP::BdTran.api_translate(lines, tl: "vie", retry: false, cache: true)
      Log.info { "- #{trans.size} lines, total chars: #{char_total}".colorize.green }
    end

    orig_size = crits.sum(&.lines.size)
    raise "size mismatch #{trans.size} #{orig_size}" if trans.size != orig_size

    start = 0
    crits.each do |ycrit|
      count = ycrit.lines.size
      vi_bd = trans[start, count]
      PGDB.exec UPDATE_SQL, vi_bd.join('\n'), ycrit.id
      start += count
    end
  rescue ex
    Log.warn { ex.message.colorize.red }
    sleep 10.seconds
  end
end
