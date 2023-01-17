require "./_m1_ctrl_base"

require "../data/v1_dict"
require "../data/v1_defn"

class M1::DictCtrl < AC::Base
  base "/_m1"

  @[AC::Route::GET("/dicts")]
  def index
    pg_no, limit, offset = _paginate(min: 20, max: 50)

    cores = DbDict.all_cores
    books = DbDict.all_books(limit: limit, offset: offset)
    total = DbDict.books_count

    output = {
      cores: cores,
      books: books,
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: output
  end

  @[AC::Route::GET("/dicts/:name")]
  def show(name : String)
    raise "Từ điển không tồn tại!" unless dict = DbDict.get(name)

    output = {
      dname: dict.dname,
      label: dict.label,
      brief: dict.brief,

      dsize: dict.term_total,
      defns: dict.term_avail,

      users: dict.users.split(',', remove_empty: true),
    }

    render json: output
  end
end
