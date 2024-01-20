require "./_mt_ctrl_base"
require "../data/pg_pair"
require "../core/mt_data/pair_dict"

class MT::ZvPairCtrl < AC::Base
  base "/_ai/zvpairs"

  @[AC::Route::GET("/")]
  def index(dname : String? = nil,
            a_key : String? = nil,
            b_key : String? = nil,
            uname : String? = nil)
    pg_no, limit, offset = _paginate(min: 10, max: 100)
    terms, total = PgPair.fetch_page(dname, a_key, b_key, uname, limit, offset)

    json = {
      items: terms,
      start: offset &+ 1,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: json
  end

  @[AC::Route::PUT("/once", body: :zform)]
  def upsert_once(zform : PgPair)
    guard_privi 2, "thêm sửa cặp nghĩa từ"

    zform.uname = self._uname
    zform.mtime = TimeUtil.cv_mtime

    spawn do
      log_path = PgPair.db_path.sub(".db3", ".log")
      File.open(log_path, "a", &.puts(zform.to_json))
      PgPair.db.open_rw { |db| zform.upsert!(db: db) }
    end

    PairDict.load!(zform.dname).add!(zform)

    render text: "ok"
  end

  @[AC::Route::GET("/find")]
  def show(dname : String, a_key : String, b_key : String)
    entry = PgPair.find(dname: dname, a_key: a_key, b_key: b_key)

    if entry
      render json: entry
    else
      render :not_found, text: "Không tồn tại"
    end
  end
end
