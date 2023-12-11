require "./_mt_ctrl_base"
require "./vi_term_form"
require "./zv_term_view"

class MT::ViTermCtrl < AC::Base
  base "/_ai/terms"

  @[AC::Route::GET("/")]
  def index(d_id : Int32,
            zstr : String? = nil,
            vstr : String? = nil,
            cpos : String? = nil,
            attr : String? = nil,
            uname : String? = nil,
            plock : Int16? = nil)
    pg_no, limit, offset = _paginate(min: 10, max: 100)

    terms, total = ZvtermView.fetch_all(
      d_id: d_id, zstr: zstr, cpos: cpos,
      vstr: vstr, attr: attr,
      uname: uname, plock: plock,
      limit: limit, offset: offset,
    )

    json = {
      items: terms,
      start: offset &+ 1,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: json
  end

  LOG_DIR = "var/ulogs/mtapp"
  Dir.mkdir_p(LOG_DIR)

  @[AC::Route::PUT("/once", body: :tform)]
  def upsert_once(tform : ViTermForm)
    _log_action("once", tform, ldir: LOG_DIR)
    tform.save!(uname: self._uname, privi: self._privi)
    render text: "ok"
  end

  @[AC::Route::GET("/find")]
  def show(d_id : Int32, zstr : String, cpos : String)
    term = ZvTerm.find(d_id: d_id, zstr: zstr, cpos: cpos)

    if term
      render json: term
    else
      render :not_found, text: "Không tồn tại"
    end
  end
end
