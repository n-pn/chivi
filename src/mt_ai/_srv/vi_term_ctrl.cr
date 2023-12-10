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

  @[AC::Route::PUT("/once", body: :form)]
  def upsert_once(form : ViTermForm)
    _log_action("once", form, ldir: LOG_DIR)

    prev_term = form.prev_term

    min_plock = prev_term ? prev_term.plock : 0
    min_privi = ZvDict::Kind.p_min(form.dname) + min_plock

    if _privi < min_privi
      raise Unauthorized.new "Bạn cần quyền hạn tối thiểu là #{min_privi} để thêm/sửa từ"
    end

    if form.plock < min_plock && _privi < min_privi &+ 1
      raise Unauthorized.new "Từ đã bị khoá, bạn cần quyền hạn tối thiểu là #{min_privi + 1} để đổi khoá"
    end

    spawn form.save_to_disk!(_uname, on_create: prev_term.nil?)

    form.sync_with_dict!
    render text: "ok"
  end

  @[AC::Route::GET("/find")]
  def show(dict : String, zstr : String, cpos : String)
    dict = dict.sub(':', '/')
    term = ViTerm.find(dict: dict, zstr: zstr, cpos: cpos)

    if term
      render json: term
    else
      render :not_found, text: "Không tồn tại"
    end
  end
end
