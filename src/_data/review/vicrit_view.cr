require "../_data"

struct CV::VicritView
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  getter vc_id : Int32
  getter vu_id : Int32
  getter wn_id : Int32
  getter vl_id : Int32

  getter u_uname : String
  getter u_privi : Int32

  getter b_uslug : String
  getter b_title : String

  getter l_title : String
  getter l_uslug : String
  getter l_count : Int32

  getter stars : Int32
  getter ohtml : String
  getter btags : Array(String)

  getter like_count : Int32
  getter repl_count : Int32

  getter ctime : Int64
  getter utime : Int64

  getter me_liked : Int64 = 0

  TARGET_TYPE = 42 # FIXME: sync with Memoir::Type

  private def self.build_query(&)
    String.build do |sql|
      sql << <<-SQL
      select
        t.*, coalesce(m.liked_at, 0) as me_liked
      from vicrits_view as t
        left join memoirs as m
          on m.target_id = t.vc_id
          and m.target_type = #{TARGET_TYPE}
          and m.viuser_id = $1
      SQL

      yield sql
    end
  end

  def self.fetch_one(crit_id : Int32, self_id = 0) : self
    stmt = build_query { |sql| sql << " where t.vc_id = $2" }
    PGDB.query_one stmt, self_id, crit_id, as: self
  end

  private def self.where_vuser(sql : IO, idx : Int32)
    sql << " and t.vu_id = (select id from viusers where uname = $#{idx})"
    idx &+ 1
  end

  private def self.where_wbook(sql : IO, idx : Int32)
    sql << " and t.wn_id = $#{idx}"
    idx &+ 1
  end

  private def self.where_vlist(sql : IO, idx : Int32)
    sql << " and t.vl_id = $#{idx}"
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
      sql << " where 1=1"

      idx = 4
      idx = where_vuser(sql, idx) if vuser
      idx = where_wbook(sql, idx) if wbook
      idx = where_vlist(sql, idx) if vlist
      idx = where_btags(sql, idx) if btags
      idx = where_s_min(sql, idx) if s_min
      idx = where_s_max(sql, idx) if s_max

      case order
      when "ctime" then sql << " order by t.vc_id desc"
      when "utime" then sql << " order by t.vc_id desc"
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
  )
    # TODO: restrict limit when the review tally is large enough
    args = {vuser, wbook, vlist, btags, s_min, s_max}.reject(Nil)

    stmt = String.build do |sql|
      sql << <<-SQL
        select coalesce(count(*)::int, 0) from vicrits_view as t
        where 1 = 1
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

  # def self.inc_counter(id : Int32, field : String, value : Int32)
  #   PGDB.exec "update #{@@table} set #{field} = #{field} + $1 where id = $2", value, id
  # end

end
