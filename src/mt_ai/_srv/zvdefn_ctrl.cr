require "./_mt_ctrl_base"

require "./zvdefn_form"
require "./zvdefn_view"

class MT::ZvdefnCtrl < AC::Base
  base "/_ai/zvdefns"

  @[AC::Route::GET("/")]
  def index(d_id : Int32,
            zstr : String? = nil,
            vstr : String? = nil,
            cpos : String? = nil,
            attr : String? = nil,
            uname : String? = nil,
            plock : Int16? = nil)
    pg_no, limit, offset = _paginate(min: 10, max: 100)

    terms, total = ZvdefnView.fetch_all(
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

  @[AC::Route::PUT("/once", body: :dform)]
  def upsert_once(dform : ZvdefnForm)
    spawn self._log_action("zvdefn-once", data: dform, ldir: LOG_DIR)

    zv_dict, zv_defn = dform.to_pg(self._vu_id, self._uname, self._privi)
    sq_defn = SqDefn.new(zv_defn)

    spawn do
      zv_defn.upsert!
      sq_defn.upsert!(db: SqDefn.load_db(zv_dict.d_id))
    end

    if zv_defn.plock < 0
      TrieDict.del_defn(zv_dict.name, input: sq_defn)
    else
      TrieDict.add_defn(zv_dict.name, input: sq_defn)
    end

    render text: "ok"
  end

  @[AC::Route::GET("/find")]
  def show(d_id : Int32, zstr : String, cpos : String)
    term = PgDefn.find(d_id: d_id, zstr: zstr, cpos: cpos)

    if term
      render json: term
    else
      render :not_found, text: "Không tồn tại"
    end
  end
end
