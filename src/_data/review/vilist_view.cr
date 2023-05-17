require "../_data"

struct CV::VilistCard
  class_getter table = "vilists"

  include DB::Serializable
  include JSON::Serializable

  getter user_id : Int32
  getter u_uname : String
  getter u_privi : Int32

  getter vl_id : Int32
  getter tslug : String

  getter title : String
  getter dhtml : String
  getter klass : String

  getter covers : Array(String)
  getter genres : Array(String)

  getter ctime : Int64
  getter utime : Int64

  getter book_count : Int32
  getter like_count : Int32
  getter view_count : Int32

  getter me_liked : Int64 = 0

  TARGET_TYPE = 41 # FIXME: sync with Memoir::Type

  private def self.build_query(&)
    String.build do |sql|
      sql << <<-SQL
      select
        u.id as user_id,
        u.uname as u_uname,
        u.privi as u_privi,

        t.id as vl_id,
        (t.id || '-' || t.tslug) as tslug,

        t.title as title,
        t.klass as klass,
        t.dhtml as dhtml,

        t.covers,
        t.genres,

        extract(epoch from t.created_at)::bigint as ctime,
        extract(epoch from t.updated_at)::bigint as utime,

        t.book_count,
        t.like_count,
        t.view_count,

        coalesce(m.liked_at, 0) as me_liked
      from #{@@table} as t
        inner join viusers as u
          on u.id = t.viuser_id
        left join memoirs as m
          on m.target_id = t.id
          and m.target_type = #{TARGET_TYPE}
          and m.viuser_id = $1
      SQL

      yield sql
    end
  end

  def self.fetch_one(list_id : Int32, self_id = 0) : self
    stmt = build_query { |sql| sql << " where t.id = $2" }
    PGDB.query_one stmt, self_id, list_id, as: self
  end

  private def self.where_vuser(sql : IO, idx : Int32)
    sql << " and t.viuser_id = (select id from viusers where uname = $#{idx}) "
    idx &+ 1
  end

  private def self.where_klass(sql : IO, idx : Int32)
    sql << " and t.klass = $#{idx}"
    idx &+ 1
  end

  private def self.where_wbook(sql : IO, idx : Int32)
    sql << " and t.id in (select vilist_id from vicrits where nvinfo_id = $#{idx})"
    idx &+ 1
  end

  private def self.where_query(sql : IO, idx : Int32)
    sql << " and t.tslug like '%' || $#{idx} || '%'"
    idx &+ 1
  end

  def self.count_all(
    vuser : String? = nil,
    klass : String? = nil,
    wbook : Int32? = nil,
    query : String? = nil
  ) : Int32
    args = {vuser, klass, wbook, query}.reject(Nil)

    stmt = String.build do |sql|
      sql << <<-SQL
        select coalesce(count(*)::int, 0) from #{@@table} as t
        where book_count > 0
        SQL

      idx = 1
      idx = where_vuser(sql, idx) if vuser
      idx = where_klass(sql, idx) if klass
      idx = where_wbook(sql, idx) if wbook
      where_query(sql, idx) if query
    end

    PGDB.query_one stmt, args: args, as: Int32
  end

  def self.all_by_user(user_id : Int32, self_id : Int32 = 0) : Array(self)
    stmt = build_query do |sql|
      sql << " where t.viuser_id = $2 order by t.updated_at desc"
    end

    PGDB.query_all stmt, user_id, self_id, as: self
  end

  def self.fetch_all(
    self_id : Int32 = 0,
    order : String = "utime",
    vuser : String? = nil,
    klass : String? = nil,
    wbook : Int32? = nil,
    query : String? = nil,
    limit : Int32 = 10,
    offset : Int32 = 0
  ) : Array(self)
    args = {self_id, limit, offset, vuser, klass, wbook, query}.reject(Nil)

    stmt = build_query do |sql|
      sql << " where book_count > 0"

      idx = 4
      idx = where_vuser(sql, idx) if vuser
      idx = where_klass(sql, idx) if klass
      idx = where_wbook(sql, idx) if wbook
      where_query(sql, idx) if query

      case order
      when "ctime" then sql << " order by t.id desc"
      when "likes" then sql << " order by t.like_count desc"
      when "stars" then sql << " order by t.view_count desc"
      else              sql << " order by t._sort desc"
      end

      sql << " limit $2 offset $3"
    end

    PGDB.query_all stmt, args: args, as: self
  end

  def self.inc_counter(id : Int32, field : String, value : Int32)
    PGDB.exec "update #{@@table} set #{field} = #{field} + $1 where id = $2", value, id
  end

  def self.get_dtext(id : Int32) : String
    PGDB.query_one "select dtext from #{@@table} where id = $1", id, as: String
  end
end
