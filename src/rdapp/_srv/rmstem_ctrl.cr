require "./_ctrl_base"

class RD::RmstemCtrl < AC::Base
  base "/_rd/rmstems"

  @[AC::Route::GET("/")]
  def index(
    wn wn_id : Int32? = nil,
    sn sname : String? = nil,
    lb genre : String? = nil,
    st status : Int32? = nil,
    bt btitle : String? = nil,
    by author : String? = nil,
    _s order : String = "rtime"
  )
    pg_no, limit, offset = _paginate(min: 25, max: 100)

    query, args = Rmstem.build_select_sql(
      btitle: btitle,
      author: author,
      status: status,
      wn_id: wn_id,
      sname: sname,
      genre: genre,
      order: order,
    )
    args << limit << offset

    items = Rmstem.db.query_all(query, args: args, as: Rmstem)

    if items.size < limit
      total = items.size &+ offset
    else
      query = query.sub("select *", "select chap_count")
      args[-2] = limit &* 3
      total = Rmstem.db.query_all(query, args: args, as: Int32).size &+ offset
    end

    json = {
      items: items,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: json
  end

  # @[AC::Route::POST("/", body: form)]
  # def create(form : Rmstem)
  #   guard_privi 1, "tạo dự án cá nhân"

  #   form.id = nil
  #   form.sname = "@#{_uname}"
  #   form.viuser_id = _vu_id
  #   form.wninfo_id = nil if form.wninfo_id == 0

  #   saved = form.insert!
  #   saved.mkdirs!

  #   render json: saved
  # end

  @[AC::Route::GET("/:sname/:sn_id")]
  def show(sname : String, sn_id : String)
    render json: get_rstem(sname, sn_id)
  end

  # @[AC::Route::POST("/:up_id", body: form)]
  # def update(up_id : Int32, form : Rmstem)
  #   guard_privi 1, "sửa dự án cá nhân"

  #   unless term = Rmstem.find(up_id, _privi < 4 ? _uname : nil)
  #     render 404, "Dự án không tồn tại hoặc bạn không đủ quyền hạn"
  #     return
  #   end

  #   term.zname = form.zname unless form.zname.empty?
  #   term.vname = form.vname unless form.vname.empty?

  #   term.wninfo_id = form.wninfo_id

  #   term.vintro = form.vintro
  #   term.labels = form.labels

  #   term.updated_at = Time.utc

  #   saved = term.update!
  #   render json: saved
  # end

  # @[AC::Route::PATCH("/:up_id", body: form)]
  # def config(up_id : Int32, form : Rmstem)
  #   guard_privi 1, "sửa dự án cá nhân"

  #   unless term = Rmstem.find(up_id, _privi < 4 ? _uname : nil)
  #     render 404, "Dự án không tồn tại hoặc bạn không đủ quyền hạn"
  #     return
  #   end

  #   term.guard = form.guard
  #   term.wndic = form.wndic
  #   term.gifts = form.gifts
  #   term.multp = form.multp
  #   term.updated_at = Time.utc

  #   saved = term.update!
  #   render json: saved
  # end

  # @[AC::Route::DELETE("/:up_id")]
  # def delete(up_id : Int32)
  #   guard_privi 1, "xóa dự án cá nhân"
  #   uname = _privi < 4 ? _uname : nil

  #   unless term = Rmstem.find(up_id, uname)
  #     raise BadRequest.new("Dự án không tồn tại hoặc bạn không đủ quyền hạn")
  #   end

  #   Rmstem.db.exec("delete from upstems where id = $1", term.id)
  #   render text: "ok"
  # end
end
