require "./_ctrl_base"

require "../data/v1_dict"
require "../data/v1_defn"

class M1::DictCtrl < M1::BaseCtrl
  base "/_m1"

  @[AC::Route::GET("/dicts")]
  def index(page : Int32 = 1, take : Int32 = 20)
    pgidx, limit, offset = CtrlUtil.paginated(page, take)

    total = DbDict.bdicts_count
    cores = [DbDict.get!(1)]
    books = DbDict.bdicts_all(limit: limit, offset: offset)

    output = {
      cores: cores.map(&.tuple),
      books: books.map(&.tuple),
      total: total,
      pgidx: pgidx,
      pgmax: CtrlUtil.pg_no(total, limit),
    }

    render json: output
  end

  @[AC::Route::GET("/dicts/:name")]
  def query(name : String)
    dict = DbDict.get!(name)

    output = {
      dname: dict.dname,
      d_dub: dict.label,
      brief: dict.brief,

      dsize: dict.term_total,
      defns: dict.term_avail,
    }

    render json: output
  end
end
