require "./_ctrl_base"

class RD::UpstemCtrl < AC::Base
  base "/_rd/upstems"

  @[AC::Route::GET("/")]
  def index(
    wn wn_id : Int32? = nil,
    by uname : String? = nil,
    lb label : String? = nil,
    kw title : String? = nil,
    _s order : String = "time",
    _m qmode : String = "index"
  )
    pg_no, limit, offset = _paginate(min: 25, max: 100)

    if qmode == "owner"
      guard = 4
      uname = _uname
    else
      guard = _privi
    end

    query, args = Upstem.build_select_sql(
      guard: guard, uname: uname,
      wn_id: wn_id, label: label,
      title: title, order: order,
    )

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

  @[AC::Route::POST("/", body: uform)]
  def create(uform : Upstem)
    guard_privi 1, "tạo dự án cá nhân"

    uform.id = nil
    uform.sname = "@#{_uname}"
    uform.owner = _vu_id
    uform.wn_id = nil if uform.wn_id == 0

    ustem = uform.insert!
    Dir.mkdir_p("var/stems/up#{uform.sname}")

    render json: ustem
  end

  @[AC::Route::GET("/:up_id")]
  def show(up_id : Int32)
    render json: get_ustem(up_id)
  end

  @[AC::Route::POST("/:up_id", body: form)]
  def update(up_id : Int32, form : Upstem)
    guard_privi 1, "sửa dự án cá nhân"

    unless term = Upstem.find(up_id, _privi < 4 ? _uname : nil)
      render 404, "Dự án không tồn tại hoặc bạn không đủ quyền hạn"
      return
    end

    term.zname = form.zname unless form.zname.empty?
    term.vname = form.vname unless form.vname.empty?

    term.wn_id = form.wn_id

    term.vintro = form.vintro
    term.labels = form.labels

    term.updated_at = Time.utc

    saved = term.update!
    render json: saved
  end

  @[AC::Route::PATCH("/:up_id", body: form)]
  def config(up_id : Int32, form : Upstem)
    guard_privi 1, "sửa dự án cá nhân"

    unless term = Upstem.find(up_id, _privi < 4 ? _uname : nil)
      render 404, "Dự án không tồn tại hoặc bạn không đủ quyền hạn"
      return
    end

    term.guard = form.guard
    term.wndic = form.wndic
    term.gifts = form.gifts
    term.multp = form.multp
    term.updated_at = Time.utc

    saved = term.update!
    render json: saved
  end

  @[AC::Route::DELETE("/:up_id")]
  def delete(up_id : Int32)
    guard_privi 1, "xóa dự án cá nhân"
    uname = _privi < 4 ? _uname : nil

    unless term = Upstem.find(up_id, uname)
      raise BadRequest.new("Dự án không tồn tại hoặc bạn không đủ quyền hạn")
    end

    Upstem.db.exec("delete from upstems where id = $1", term.id)
    render text: "ok"
  end
end
