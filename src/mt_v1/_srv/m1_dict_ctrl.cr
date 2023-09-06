require "./_m1_ctrl_base"

require "../data/v1_dict"
require "../data/v1_defn"

class M1::DictCtrl < AC::Base
  base "/_m1/dicts"

  @[AC::Route::GET("/")]
  def index
    pg_no, limit, offset = _paginate(min: 20, max: 50)

    cores = ViDict.all_cores
    books = ViDict.all_books(limit: limit, offset: offset)
    total = ViDict.books_count

    output = {
      cores: cores,
      books: books,
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: output
  end

  private def get_dict(dname : String)
    ViDict.find(dname) || raise NotFound.new("Từ điển không tồn tại!")
  end

  @[AC::Route::GET("/:name")]
  def show(name : String)
    dict = get_dict(name)

    output = {
      vp_id: dict.id,
      dname: dict.dname,

      label: dict.label,
      brief: dict.brief,

      dsize: dict.term_total,
      defns: dict.term_avail,

      users: dict.users.split(',', remove_empty: true),
    }

    render json: output
  end

  @[AC::Route::PUT("/")]
  def upsert(wn_id : Int32, bslug : String, bname : String)
    ViDict.init_wn_dict!(wn_id, bslug, bname)
    render text: wn_id
  end

  @[Flags]
  enum ExportTabs
    Main; Temp; User
  end

  @[AC::Route::GET("/:name/export")]
  def export(name : String,
             temp : Bool = false, user : Bool = true,
             scope : String = "all", format : String = "qt")
    dict = get_dict(name)

    guard_privi dict.privi, "tải từ điển"

    query = String.build do |io|
      io << "select key, val, ptag, prio from defns "
      io << "where dic = $1 and (tab = 1"
      io << " or tab = 2" if temp
      io << " or (tab = 3 and uname = '#{_uname}')" if user
      io << ')'
      io << " limit 10000 order by id desc" if scope != "all"
    end

    terms = DbDefn.db.query_all(query, dict.id, as: {String, String, String, Int32})

    output = String.build do |strio|
      if format == "qt"
        terms.join(strio, "\n") { |(key, val), io| io << key << '=' << val }
      else
        terms.join(strio, "\n") { |rows, io| rows.join(io, '\t') }
      end
    end

    response.headers["Content-Type"] = %{text/plain; charset=utf-8}
    render text: output
  end
end
