require "./_ctrl_base"

require "../data/v1_dict"
require "../data/v1_defn"

class M1::DictCtrl < M1::BaseCtrl
  base "/_m1"

  @[AC::Route::GET("/defns")]
  def index(dic : String?, tab : Int32?,
            key : String?, val : String?,
            ptag : String?, prio : String?,
            uname : String?,
            pg pg_no : Int32 = 1, lm limit : Int32 = 50)
    limit = 100 if limit > 100
    offset = (pg_no - 1) * limit

    args = [] of DB::Any

    query = String.build do |sql|
      sql << "select * from defns where _flag > -3"

      if dic
        sql << " and dic = ?"
        args << DbDict.get_id(dic)
      end

      if tab
        sql << " and tab = ?"
        args << tab
      end

      if key
        sql << " and key ilike ?"
        args << regex_to_ilike(key)
      end

      if val
        sql << " and val ilike ?"
        args << regex_to_ilike(val)
      end

      if ptag
        sql << " and ptag = ?"
        args << ptag
      end

      if prio
        sql << " and prio = ?"
        args << prio
      end

      if uname
        sql << " and uname = ?"
        args << uname
      end

      sql << " order by id desc"
      sql << " limit ? offset ?"
      args << limit << offset
    end

    terms = DbDefn.repo.open_db do |db|
      db.query_all query, args: args, as: DbDefn
    end

    total = DbDefn.repo.open_db do |db|
      query = query.sub("select * ", "select count (*) ")
      args[-2] = args[-2].as(Int32) + limit * 2
      db.query_one(query, args: args, as: Int32)
    end

    render json: {
      terms: terms,
      total: total,
      pgidx: pgidx,
      pgmax: CtrlUtil.pg_no(total, limit),
    }
  end

  private def regex_to_ilike(str : String)
    str = str.starts_with?('^') ? str[1..] : "%" + str
    str = str.ends_with?('$') ? str[..-2] : str + "%"

    str
  end
end
