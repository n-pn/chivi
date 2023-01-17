require "./_ctrl_base"

require "../data/v1_dict"
require "../data/v1_defn"

class M1::DefnCtrl < M1::BaseCtrl
  base "/_m1"

  @[AC::Route::GET("/defns")]
  def index(dic : String?, tab : Int32?,
            key : String?, val : String?,
            ptag : String?, prio : Int32?,
            uname : String?,
            pg pg_no : Int32 = 1, lm limit : Int32 = 50)
    limit = 100 if limit > 100
    offset = (pg_no - 1) * limit

    query, args = build_query(params, limit, offset)

    terms = DbDefn.repo.open_db do |db|
      db.query_all query, args: args, as: DbDefn
    end

    total = terms.size

    if total == limit
      total = DbDefn.repo.open_db do |db|
        query = query.sub("select * ", "select count (*) ")
        args[-2] = args[-2].as(Int32) + limit * 2
        args[-1] = 0
        db.query_one(query, args: args, as: Int32)
      end
    end

    render json: {
      terms: terms,
      total: total,
      pgidx: pg_no,
      start: offset + 1,
      pgmax: CtrlUtil.pg_no(total, limit),
    }
  end

  private def get_str(name : String)
    params[name]?.try { |x| x unless x.blank? }
  end

  private def get_int(name : String)
    params[name]?.try(&.to_i?)
  end

  private def build_query(params, limit, offset)
    args = [] of DB::Any

    query = String.build do |sql|
      sql << "select * from defns where _flag > -2"

      if dic = get_str("dic")
        sql << " and dic = ?"
        args << DbDict.get_id(dic)
      end

      if tab = get_int("tab")
        sql << " and tab = ?"
        args << tab
      end

      if key = get_str("key")
        sql << " and key like ?"
        args << regex_to_like(key)
      end

      if val = get_str("val")
        sql << " and val like ?"
        args << regex_to_like(val)
      end

      if ptag = get_str("ptag")
        sql << " and ptag = ?"
        args << ptag
      end

      if prio = get_int("prio")
        sql << " and prio = ?"
        args << prio
      end

      if uname = get_str("uname")
        sql << " and uname = ?"
        args << uname
      end

      sql << " order by id desc"
      sql << " limit ? offset ?"

      args << limit << offset
    end

    {query, args}
  end

  private def regex_to_like(str : String)
    str = str.starts_with?('^') ? str[1..] : "%" + str
    str = str.ends_with?('$') ? str[..-2] : str + "%"

    str
  end
end
