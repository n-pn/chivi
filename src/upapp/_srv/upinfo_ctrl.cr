require "./_up_ctrl_base"

class UP::UpinfoCtrl < AC::Base
  base "/_up/projs"

  @[AC::Route::GET("/")]
  def index(uname : String? = nil)
    pg_no, limit, offset = _paginate(min: 25, max: 100)

    items = Upinfo.get_all(uname, limit, offset)
    total = items.size == limit ? limit &+ 1 : limit

    json = {
      items: items,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: json
  end

  @[AC::Route::POST("/", body: form)]
  def create(form : Upinfo)
    guard_privi 1, "tạo dự án cá nhân"

    form.id = nil
    form.viuser_id = _vu_id
    form.wninfo_id = nil if form.wninfo_id == 0

    saved = form.insert!
    render json: saved
  end

  @[AC::Route::GET("/:up_id")]
  def show(up_id : Int32)
    if info = Upinfo.find(up_id)
      render json: info
    else
      render 404, text: "Dự án không tồn tại"
    end
  end

  @[AC::Route::POST("/:up_id", body: form)]
  def update(up_id : Int32, form : Upinfo)
    guard_privi 1, "sửa dự án cá nhân"

    unless term = Upinfo.find(up_id, _privi < 4 ? _uname : nil)
      render 404, "Dự án không tồn tại hoặc bạn không đủ quyền hạn"
      return
    end

    form.viuser_id = term.viuser_id
    form.mtime = term.mtime

    form.created_at = term.created_at
    form.chap_count = term.chap_count
    form.word_count = term.word_count

    saved = form.update!
    render json: saved
  end
end
