require "../src/_data/zr_db"
require "../src/mt_ai/_raw/*"
require "../src/mt_ai/data/shared/*"

class MCache
  class_getter db : DB::Database = ZR_DB

  include Crorm::Model

  schema "mcache", :postgres

  field rid : Int64, pkey: true
  field ver : Int16, pkey: true
  field tid : Int32, pkey: true

  field con : MT::RawCon = MT::RawCon.new("X"), converter: MT::RawCon

  def pos_from_con
    pos = [] of Int16
    queue = @con.body.as(Array(MT::RawCon))

    queue.each do |rcon|
      epos = MT::MtEpos.parse?(rcon.cpos.split('-').first) || MT::MtEpos::X
      pos << epos.to_i16
      body = rcon.body
      queue.concat(body) if body.is_a?(Array)
    end

    pos.uniq!
  end
end

select_query = "select rid, ver, tid, con from mcache where pos = '{}'::smallint[] limit 200"
update_query = "update mcache set pos = $1 where rid = $2 and ver = $3 and tid = $4"

(1..).each do |index|
  input = ZR_DB.query_all select_query, as: MCache
  break if input.empty?
  ZR_DB.transaction do |tx|
    input.each do |m|
      tx.connection.exec update_query, m.pos_from_con, m.rid, m.ver, m.tid
    end

    puts "- #{index}: #{input.size} updated"
  end
end
