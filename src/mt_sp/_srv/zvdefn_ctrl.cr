require "./_sp_ctrl_base"

require "./zvdefn_form"
require "./zvdefn_view"

class SP::ZvdefnCtrl < AC::Base
  base "/_sp/zvdefns"

  @[AC::Route::GET("/")]
  def index(dict : String? = nil, zstr : String? = nil, cpos : String? = nil,
            vstr : String? = nil, attr : String? = nil, rank : Int16? = nil,
            user : String? = nil, lock : Int16? = nil)
    pg_no, limit, offset = _paginate(min: 10, max: 100)

    terms, total = ZvdefnView.fetch_all(
      dict: dict, zstr: zstr, cpos: cpos,
      vstr: vstr, attr: attr, rank: rank,
      user: user, lock: lock,
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

  LOG_DIR = "var/ulogs/mt_db"
  Dir.mkdir_p(LOG_DIR)

  @[AC::Route::PUT("/once", body: :dform)]
  def upsert_once(dform : ZvdefnForm)
    spawn self._log_action("zvdefn-once", data: dform, ldir: LOG_DIR)

    dict, defn = dform.to_pg(self._vu_id, self._uname, self._privi)
    defn.upsert!
    # TODO: increase counter for dict

    render json: defn
  end

  @[AC::Route::GET("/find")]
  def show(dict : String, zstr : String, cpos : String)
    term = Zvdefn.find(dict: dict, zstr: zstr, cpos: cpos)

    if term
      render json: term
    else
      render :not_found, text: "Không tồn tại"
    end
  end
end
