require "../_data"

struct CV::GdreplCard
  class_getter table = "gdrepls"

  include DB::Serializable
  include JSON::Serializable

  getter user_id : Int32
  getter u_uname : String
  getter u_privi : Int32

  getter gdroot : Int32
  getter touser : Int32
  getter torepl : Int32

  getter rp_id : Int32
  getter level : Int16
  getter ohtml : String

  getter ctime : Int64
  getter utime : Int64

  getter like_count : Int32
  getter repl_count : Int32

  getter vcoin : Int32

  @[DB::Field(ignore: true)]
  getter repls = [] of Int32

  getter me_liked : Int64 = 0

  def self.fetch_one(repl_id : Int32, self_id = 0)
    stmt = build_query { |sql| sql << " where r.id = $2" }
    PGDB.query_one stmt, self_id, repl_id, as: self
  end

  def self.by_thread(
    root_id : Int32,
    self_id : Int32 = 0,
    limit : Int32 = 20,
    offset : Int32 = 0
  )
    select_stmt = build_query do |sql|
      sql << <<-SQL
        where r.id > 0 and r.gdroot_id = $2
        order by r.id desc limit $3 offset $4
        SQL
    end

    PGDB.query_all select_stmt, self_id, root_id, limit, offset, as: self
  end

  TARGET_TYPE = 11 # FIXME: sync with Memoir::Type

  def self.build_query(&)
    String.build do |sql|
      sql << <<-SQL
      select
        u.id as user_id,
        u.uname as u_uname,
        u.privi as u_privi,

        r.gdroot_id as gdroot,
        r.touser_id as touser,
        r.torepl_id as torepl,

        r.id as rp_id,
        r.level,
        r.ohtml,
        r.gift_vcoin as vcoin,

        extract(epoch from r.created_at)::bigint as ctime,
        r.utime,

        r.like_count,
        r.repl_count,

        coalesce(m.liked_at, 0) as me_liked
      from #{@@table} as r
        inner join viusers as u
          on u.id = r.viuser_id
        left join memoirs as m
          on m.target_id = r.id
          and m.target_type = #{TARGET_TYPE}
          and m.viuser_id = $1

      SQL

      yield sql
    end
  end

  def self.inc_counter(id : Int32, field : String, value : Int32)
    PGDB.exec "update #{@@table} set #{field} = #{field} + $1 where id = $2", value, id
  end
end
