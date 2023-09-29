require "./_up_ctrl_base"

class UP::UpstemCtrl < AC::Base
  base "/_up/stems"

  @[AC::Route::GET("/")]
  def index(
    _s order : String = "time",
    by uname : String? = nil,
    lb label : String? = nil,
    wn wn_id : Int32? = nil
  )
    pg_no, limit, offset = _paginate(min: 25, max: 100)

    query, args = Upstem.build_select_sql(_privi, order, uname, label, wn_id)
    args << limit << offset

    items = Upstem.db.query_all(query, args: args, as: Upstem)

    if items.size < limit
      total = items.size &+ offset
    else
      query = query.sub("select *", "select id")
      args[-2] = offset &+ limit &* 3
      args[-1] = 0
      total = Upstem.db.query_all(query, args: args, as: Int32).size
    end

    json = {
      items: items,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: json
  end

  @[AC::Route::POST("/", body: form)]
  def create(form : Upstem)
    guard_privi 1, "tạo dự án cá nhân"

    form.id = nil
    form.sname = "@#{_uname}"
    form.viuser_id = _vu_id
    form.wninfo_id = nil if form.wninfo_id == 0

    saved = form.insert!
    saved.mkdirs!

    render json: saved
  end

  @[AC::Route::GET("/:up_id")]
  def show(up_id : Int32)
    if ustem = Upstem.find(up_id)
      json = {ustem: ustem, chaps: ustem.top_chaps(4)}
      render json: json
    else
      render 404, text: "Dự án không tồn tại"
    end
  end

  @[AC::Route::POST("/:up_id", body: form)]
  def update(up_id : Int32, form : Upstem)
    guard_privi 1, "sửa dự án cá nhân"

    unless term = Upstem.find(up_id, _privi < 4 ? _uname : nil)
      render 404, "Dự án không tồn tại hoặc bạn không đủ quyền hạn"
      return
    end

    form.viuser_id = term.viuser_id

    form.sname = term.sname
    form.mtime = term.mtime

    form.created_at = term.created_at
    form.chap_count = term.chap_count
    form.word_count = term.word_count

    saved = form.update!
    render json: saved
  end
end
