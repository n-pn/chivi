require "../_data"

struct CV::VicritCard
  class_getter table = "vicrits"

  include DB::Serializable
  include JSON::Serializable

  getter user_id : Int32
  getter u_uname : String
  getter u_privi : Int32

  getter book_id : Int32
  getter b_uslug : String
  getter b_title : String

  getter list_id : Int32
  getter l_title : String
  getter l_uslug : String
  getter l_count : Int32

  getter vc_id : Int32
  getter stars : Int32
  getter ohtml : String
  getter btags : Array(String)

  getter ctime : Int64
  getter utime : Int64

  getter like_count : Int32
  getter repl_count : Int32

  getter me_liked : Int64 = 0

  TARGET_TYPE = 42 # FIXME: sync with Memoir::Type

  private def self.build_query(&)
    String.build do |sql|
      sql << <<-SQL
      select
        u.id as user_id,
        u.uname as u_uname,
        u.privi as u_privi,

        b.id as book_id,
        (b.id || '-' || b.bslug) as b_uslug,
        b.btitle_vi as b_title,

        l.id as list_id,
        l.title as l_title,
        (l.id || '-' ||  l.tslug) as l_uslug,
        l.book_count as l_count,

        t.id as vc_id,
        t.stars as stars,
        t.ohtml as ohtml,
        t.btags as btags,

        extract(epoch from t.created_at)::bigint as ctime,
        extract(epoch from coalesce(t.changed_at, t.created_at))::bigint as utime,

        t.like_count,
        t.repl_count,

        coalesce(m.liked_at, 0) as me_liked
      from #{@@table} as t
        inner join viusers as u
          on u.id = t.viuser_id
        inner join wninfos as b
          on b.id = t.nvinfo_id
        inner join vilists as l
          on l.id = t.vilist_id
        left join memoirs as m
          on m.target_id = t.id
          and m.target_type = #{TARGET_TYPE}
          and m.viuser_id = $1
      SQL

      yield sql
    end
  end

  def self.fetch_one(crit_id : Int32, self_id = 0) : self
    stmt = build_query { |sql| sql << " where t.id = $2" }
    PGDB.query_one stmt, self_id, crit_id, as: self
  end

  private def self.where_vuser(sql : IO, idx : Int32)
    sql << " and t.viuser_id = (select id from viusers where uname = $#{idx})"
    idx &+ 1
  end

  private def self.where_wbook(sql : IO, idx : Int32)
    sql << " and t.nvinfo_id = $#{idx}"
    idx &+ 1
  end

  private def self.where_vlist(sql : IO, idx : Int32)
    sql << " and t.vilist_id = $#{idx}"
    idx &+ 1
  end

  private def self.where_btags(sql : IO, idx : Int32)
    sql << " and $#{idx} = any(t.btags)"
    idx &+ 1
  end

  private def self.where_s_min(sql : IO, idx : Int32)
    sql << " and t.stars >= $#{idx}"
    idx &+ 1
  end

  private def self.where_s_max(sql : IO, idx : Int32)
    sql << " and t.stars <= $#{idx}"
    idx &+ 1
  end

  def self.fetch_all(
    self_id : Int32 = 0,
    order : String = "utime",
    vuser : String? = nil,
    wbook : Int32? = nil,
    vlist : Int32? = nil,
    btags : String? = nil,
    s_min : Int32? = nil,
    s_max : Int32? = nil,
    limit : Int32 = 10,
    offset : Int32 = 0
  ) : Array(self)
    args = {self_id, limit, offset, vuser, wbook, vlist, btags, s_min, s_max}.reject(Nil)

    stmt = build_query do |sql|
      sql << " where t.id > 0"

      idx = 4
      idx = where_vuser(sql, idx) if vuser
      idx = where_wbook(sql, idx) if wbook
      idx = where_vlist(sql, idx) if vlist
      idx = where_btags(sql, idx) if btags
      idx = where_s_min(sql, idx) if s_min
      idx = where_s_max(sql, idx) if s_max

      case order
      when "ctime" then sql << " order by t.id desc"
      when "utime" then sql << " order by t.id desc"
      when "likes" then sql << " order by t.like_count desc, t.stars desc"
      else              sql << " order by t._sort desc, t.stars desc"
      end

      sql << " limit $2 offset $3"
    end

    PGDB.query_all stmt, args: args, as: self
  end

  def self.count_all(
    vuser : String? = nil,
    wbook : Int32? = nil,
    vlist : Int32? = nil,
    btags : String? = nil,
    s_min : Int32? = nil,
    s_max : Int32? = nil
  ) : Int32
    # TODO: restrict limit when the review tally is large enough
    args = {vuser, wbook, vlist, btags, s_min, s_max}.reject(Nil)

    stmt = String.build do |sql|
      sql << <<-SQL
        select coalesce(count(*)::int, 0) from #{@@table} as t
        where t.id > 0
        SQL

      idx = 1
      idx = where_vuser(sql, idx) if vuser
      idx = where_wbook(sql, idx) if wbook
      idx = where_vlist(sql, idx) if vlist
      idx = where_btags(sql, idx) if btags
      idx = where_s_min(sql, idx) if s_min
      idx = where_s_max(sql, idx) if s_max
    end

    PGDB.query_one stmt, args: args, as: Int32
  end

  def self.inc_counter(id : Int32, field : String, value : Int32)
    PGDB.exec "update #{@@table} set #{field} = #{field} + $1 where id = $2", value, id
  end

  def self.get_form_data(id : Int32) : {Int32, String}
    PGDB.query_one <<-SQL, id, as: {Int32, String}
      select vilist_id, itext from #{@@table}
      where id = $1
      SQL
  end
end
