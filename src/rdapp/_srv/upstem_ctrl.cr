require "./_ctrl_base"

class RD::UpstemCtrl < AC::Base
  base "/_rd/upstems"

  @[AC::Route::GET("/")]
  def index(
    wn wn_id : Int32? = nil,
    by uname : String? = nil,
    lb label : String? = nil,
    kw title : String? = nil,
    _s order : String = "ctime",
    _m qmode : String = "index"
  )
    pg_no, limit, offset = _paginate(min: 25, max: 100)

    case qmode
    when "owner"
      guard = 4
      uname = self._uname
    when "liked"
      guard = 4
      liked = self._vu_id
    else
      guard = self._privi
    end

    query, args = Upstem.build_select_sql(
      guard: guard, uname: uname,
      wn_id: wn_id, label: label,
      title: title, liked: liked,
      order: order,
    )

    args << limit << offset
    items = Upstem.db.query_all(query, args: args, as: Upstem)

    if items.size < limit
      total = items.size &+ offset
    else
      query = query.sub("select *", "select id")
      args[-2] = limit &* 3
      total = Upstem.db.query_all(query, args: args, as: Int32).size &+ offset
    end

    json = {items: items, pgidx: pg_no, pgmax: _pgidx(total, limit)}
    render json: json
  end

  @[AC::Route::POST("/", body: uform)]
  def create(uform : Upstem)
    guard_privi 1, "tạo sưu tầm cá nhân"

    uform.id = nil
    uform.sname = "@#{_uname}"
    uform.owner = _vu_id
    uform.wn_id = nil if uform.wn_id.try(&.< 1)

    ustem = uform.insert!

    crepo = ustem.crepo
    crepo.mkdirs!

    # USTEMS[ustem.id!] = ustem
    render json: {
      ustem: ustem,
      crepo: crepo,
    }
  end

  @[AC::Route::POST("/:up_id", body: uform)]
  def update(up_id : Int32, uform : Upstem)
    ustem = get_ustem(up_id)
    crepo = ustem.crepo

    guard_owner ustem.owner, 1, "sửa sưu tầm cá nhân"

    unless uform.zname.empty?
      ustem.zname = uform.zname
      crepo.zname = uform.zname
    end

    unless uform.vname.empty?
      ustem.vname = uform.vname
      crepo.vname = uform.vname
    end

    if wn_id = uform.wn_id
      ustem.wn_id = wn_id
      crepo.wn_id = wn_id
    end

    ustem.vintro = uform.vintro
    ustem.labels = uform.labels

    ustem.updated_at = Time.utc

    ustem = ustem.update!
    crepo = crepo.upsert!

    render json: {
      ustem: ustem,
      crepo: crepo,
    }
  end

  @[AC::Route::PATCH("/:up_id", body: uform)]
  def config(up_id : Int32, uform : Upstem)
    ustem = get_ustem(up_id)
    guard_owner ustem.owner, 1, "sửa sưu tầm cá nhân"

    ustem.guard = uform.guard
    ustem.wndic = uform.wndic
    ustem.multp = uform.multp
    ustem.updated_at = Time.utc

    saved = ustem.update!
    render json: saved
  end

  @[AC::Route::DELETE("/:up_id")]
  def delete(up_id : Int32)
    ustem = get_ustem(up_id)
    guard_owner ustem.owner, 1, "xóa sưu tầm cá nhân"

    Upstem.db.exec("delete from upstems where id = $1", up_id)
    USTEMS.delete(up_id)

    render text: "ok"
  end
end
