require "./_mt_ctrl_base"

require "../data/db_dict"
require "../data/db_term"

class MT::DbDictCtrl < AC::Base
  base "/_ai/dicts"

  @[AC::Route::GET("/")]
  def index(dtype : DbDict::Dtype = :none)
    pg_no, limit, offset = _paginate(min: 10, max: 100)

    total = DbDict.count(dtype)
    dicts = DbDict.get_all(dtype, limit, offset)
    output = {
      dicts: dicts,
      books: books.map(&.tuple),
      total: total,
      pgidx: pgidx,
      pgmax: CtrlUtil.pg_no(total, limit),
    }

    render json: output
  end

  @[AC::Route::GET("/:dname")]
  def query(dname : String,
            zstr : String? = nil,
            vstr : String? = nil,
            cpos : String? = nil,
            prop : String? = nil,
            uname : String? = nil,
            _lock : Int32? = nil)
            dname = dname.sub(':', '/')
    dict = DbDict.find(dname)

    pg_no, limit, offset = _paginate(min: 10, max: 100)

    args = [] of DB::Any

    where_stmt = String.build do |sql|
      sql << " where 1 = 1"
      if zstr
        args << fix_query_str(zstr)
        sql << " and zstr like $" << args.size
      end

      if cpos
        args << cpos
        sql << " and cpos = $" << args.size
      end

      if vstr
        args << fix_query_str(vstr)
        sql << " and vstr like $" << args.size
      end

      if pe
        args << fix_query_str(pec)
        sql << " and pec like $" << args.size
      end

      sql << " order by mtime desc"

      args << limit
      sql << " limit $" << args.size

      args << offset
      sql << " offset $" << args.size
    end

    terms, count = DbTerm.db(dict.dname).open_ro do |db|
      terms = db.query_all("select * from terms #{query_stmt}", args, as: DbTerm)
      args[-2] = offset + limit * 3
      args[-1] = 0

      count = db.query_one("select count(*) from terms #{query_stmt}", args, as: Int32)
    end



    json = {
      dname: dict.name,
      d_dub: dict.label,
      dsize: dict.dsize,

      total: total,
      pgidx: pgidx,
      pgmax: CtrlUtil.pg_no(total, limit),

      start: offset &+ 1,
      terms: terms,
    }

    render json: output
  end

  private def fix_query_str(str : String)
    str = str.starts_with?('^') ? str[1..] : "%" + str
    str = str.ends_with?('$') ? str[..-2] : str + "%"

    str
  end

  private def build_search_query(args : Array({String, String}))
    String.build do |str|
      str << "select #{selects} from terms where dic = ? or dic = ?"
      str << " and key like ?" if key
      str << " and val like ?" if val
      str << " and ptag like ?" if ptag
      str << " and wseg = ?" if prio
      str << " order by id desc"
      str << " limit ? offset ?"
    end
  end
end
