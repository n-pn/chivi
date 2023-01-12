require "../_ctrl_base"

class CV::MarkBookCtrl < CV::BaseCtrl
  base "/api/_self/books"

  @[AC::Route::Filter(:before_action)]
  def ensure_logged_in
    render :unauthorized unless _viuser.privi >= 0
  end

  @[AC::Route::GET("/access",
    converters: {lm: ConvertLimit},
    config: {lm: {min: 15, max: 30}})]
  def access(pg pg_no : Int32 = 0, lm limit : Int32 = 15, kind : String? = nil)
    offset = CtrlUtil.offset(pg_no, limit)

    query = Ubmemo.query.where("viuser_id = ?", _viuser.id)

    case params["kind"]?
    when "marked" then query.where("locked = true")
    when "stored" then query.where("status > 0")
    end

    query = query.order_by(utime: :desc).limit(limit).offset(offset)
    render json: query.with_nvinfo.map { |x| UbmemoView.new(x, true) }
  end

  getter! book_mark : Ubmemo

  @[AC::Route::Filter(:before_action, except: [:access])]
  def get_book_mark(book_id : Int64)
    @book_mark = Ubmemo.find_or_new(_viuser.id, book_id)
  end

  @[AC::Route::GET("/:book_id")]
  def show(book_id : Int64) : Nil
    render json: UbmemoView.new(book_mark)
  end

  struct AccessData
    include JSON::Serializable

    getter sname : String, chidx : Int16, cpart : Int16
    getter title : String, uslug : String
    getter locked : Bool = false
  end

  @[AC::Route::PUT("/:book_id/access", body: :data)]
  def update_access(book_id : Int64, data : AccessData)
    book_mark.mark!(
      data.sname, data.chidx, data.cpart,
      data.title, data.uslug, data.locked ? 1 : 0
    )
    render json: UbmemoView.new(book_mark)
  end

  @[AC::Route::PUT("/:book_id/status")]
  def update_status(book_id : Int64, status = "default")
    book_mark.update!({status: status})
    render json: UbmemoView.new(book_mark)
  end
end
