require "colorize"
require "../../src/_data/zr_db"
require "../../src/mt_sp/util/bd_tran"

def gen_names_from_bd_tran
  select_sql = <<-SQL
    select zstr from zvterm
    where vi_bd is null
    order by mtime desc
    limit 500
    SQL

  update_sql = "update zvterm set vi_bd = $1 where zstr = $2"

  char_total = 0

  (1..).each do |index|
    words = ZR_DB.query_all(select_sql, as: String).uniq!
    # words.select!(&.matches?(/\p{Han}/))
    return if words.empty?

    char_count = words.sum(&.size) + words.size
    char_total += char_count

    Log.info { "- <#{index}> (#{words.size} entries)".colorize.green }
    trans = SP::BdTran.api_translate(words)
    Log.info { "  count: #{char_count}, total: #{char_total}".colorize.green }

    ZR_DB.transaction do |tx|
      trans.zip(words).each do |v_bd, zstr|
        "#{zstr} => #{v_bd}"
        tx.connection.exec update_sql, v_bd, zstr
      end
    end
  rescue ex
    Log.warn { ex.message.colorize.red }
    10.times { |i| puts "- resuming in #{10 - i} seconds..." }
  end
end

gen_names_from_bd_tran
