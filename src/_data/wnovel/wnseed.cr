require "../_data"
require "crorm"

class CV::Wnseed
  include Crorm::Model

  class_getter table = "wnseeds"
  class_getter db : DB::Database = PGDB

  field id : Int32, primary: true

  field wn_id : Int32 = 0
  field sname : String = ""
  field s_bid : Int32 = 0

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0

  field rlink : String = "" # remote page link
  field rtime : Int64 = 0   # remote sync time

  field privi : Int16 = 0
  field _flag : Int16 = 0

  field created_at : Time = Time.utc
  field updated_at : Time = Time.utc

  def initialize(@wn_id, @sname, @s_bid = wn_id, @privi = 1)
  end

  def mkdirs! : Nil
    Dir.mkdir_p("var/texts/rgbks/#{@sname}/#{@s_bid}")
    Dir.mkdir_p("var/texts/rzips/#{@sname}")
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", @sname
      jb.field "snvid", @s_bid

      jb.field "chmax", @chap_total
      jb.field "utime", @mtime

      jb.field "privi", @privi
    }
  end

  def upsert!(db = @@db)
    stmt = <<-SQL
    insert into #{@@table} (
      wn_id, sname, s_bid,
      chap_total, chap_avail,
      rlink, rtime, privi, _flag,
      created_at, updated_at
    ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    on conflict (wn_id, sname) do update set
      s_bid = excluded.s_bid,
      chap_total = excluded.chap_total,
      chap_avail = excluded.chap_avail,
      rlink = excluded.rlink, rtime = excluded.rtime,
      privi = excluded.privi, _flag = excluded._flag,
      updated_at = excluded.updated_at
    SQL

    db.exec stmt,
      @wn_id, @sname, @s_bid, @chap_total, @chap_avail,
      @rlink, @rtime, @privi, @_flag, @created_at, @updated_at
  end

  ###

  def self.find(id : Int32)
    find!(id) rescue nil
  end

  def self.find!(id : Int32)
    @@db.query_one "select * from #{@@table} where id = $1", id, as: self
  end
end
