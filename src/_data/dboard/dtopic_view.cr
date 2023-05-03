require "../_data"

struct CV::DtopicCard
  class_getter table = "dtopics"

  include DB::Serializable
  include JSON::Serializable

  getter user_id : Int32
  getter u_uname : String
  getter u_privi : Int32

  getter b_title : String
  getter b_uslug : String

  getter dt_id : Int32
  getter title : String
  getter tslug : String
  getter dtags : Array(String)
  getter bhtml : String = ""

  getter ctime : Int64
  getter utime : Int64

  getter like_count : Int32
  getter repl_count : Int32
  getter view_count : Int32

  getter me_liked : Int64 = 0

  def self.fetch_one(dtopic_id : Int32, _memo = 0)
    stmt = build_query(true) { |sql| sql << " where t.id = $2" }
    PGDB.query_one stmt, _memo, dtopic_id, as: self
  end

  def self.fetch_all(
    _memo : Int32 = 0,
    board : Int32? = nil,
    vuser : String? = nil,
    label : String? = nil,
    limit : Int32 = 20,
    offset : Int32 = 0
  )
    args = [_memo, limit, offset] of String | Int32
    cond = [] of String

    if board
      args << board
      cond << "t.nvinfo_id = ?"
    end

    if vuser
      args << vuser
      cond << "t.viuser_id = (select id from viusers where uname = ?)"
    end

    if label
      args << label
      cond << "? = any(t.lslugs)"
    end

    select_stmt = build_query(false) do |sql|
      sql << " where t.id > 0"

      cond.each_with_index(4) do |where, index|
        sql << " and " << where.sub('?', "$#{index}")
      end

      sql << " order by t._sort desc limit $2 offset $3"
    end

    items = PGDB.query_all select_stmt, args: args, as: self

    if items.size < limit
      total = offset &+ items.size
    else
      args[1] = offset &+ limit &* 3

      counter_stmt = String.build do |sql|
        sql << "select count(*)::int from #{@@table} as t"
        sql << " where t.id > 1 and $1::int is not null"

        cond.each_with_index(4) do |where, index|
          sql << " and " << where.sub('?', "$#{index}")
        end

        sql << " limit $2 offset $3"
      end

      total = PGDB.query_one counter_stmt, args: args, as: Int32
    end

    {total, items}
  end

  TARGET_TYPE = 12 # FIXME: sync with Memoir::Type

  def self.build_query(with_body : Bool = true, &)
    String.build do |sql|
      sql << <<-SQL
      select
        u.id as user_id,
        u.uname as u_uname,
        u.privi as u_privi,

        b.vname as b_title,
        (b.id || '-' || b.bslug) as b_uslug,

        t.id as dt_id,
        t.title,
        (t.id || '-' || t.tslug) as tslug,

        t.labels as dtags,
        #{with_body ? "t.bhtml," : ""}

        extract(epoch from t.created_at)::bigint as ctime,
        t.utime,

        t.like_count,
        t.repl_count,
        t.view_count,

        coalesce(m.liked_at, 0) as me_liked
      from dtopics as t
        inner join viusers as u
        on u.id = t.viuser_id
        inner join nvinfos as b
        on b.id = t.nvinfo_id
        left join memoirs as m
        on m.target_id = t.id and m.target_type = #{TARGET_TYPE} and m.viuser_id = $1
      SQL

      yield sql
    end
  end

  def self.inc_counter(id : Int32, field : String, value : Int32)
    PGDB.exec "update #{@@table} set #{field} = #{field} + $1 where id = $2", value, id
  end
end
