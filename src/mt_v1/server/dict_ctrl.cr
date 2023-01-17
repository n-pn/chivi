require "./_ctrl_base"

require "../data/v1_dict"
require "../data/v1_defn"

class M1::DictCtrl < M1::BaseCtrl
  base "/_m1"

  @[AC::Route::GET("/dicts")]
  def index(pg pg_no : Int32 = 1, lm limit : Int32 = 20)
    limit, offset = CtrlUtil.paged(pg_no, limit, max: 50)

    cores = DbDict.all_cores
    books = DbDict.all_books(limit: limit, offset: offset)
    total = DbDict.books_count

    output = {
      cores: cores,
      books: books,
      total: total,
      pgidx: pg_no,
      pgmax: CtrlUtil.pg_no(total, limit),
    }

    render json: output
  end

  @[AC::Route::GET("/dicts/:name")]
  def show(name : String)
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
