require "../_ctrl_base"
require "./murepl_form"

class CV::MureplCtrl < CV::BaseCtrl
  base "/_db/mrepls"

  @[AC::Route::GET("/")]
  def index(sort : String = "-id",
            from from_user : String? = nil, to to_user : String? = nil,
            self memo : String? = nil)
    repls = Murepl.query.where("id > 0").sort_by(sort)

    pg_no, limit, offset = _paginate(min: 20, max: 100)
    repls.limit(limit).offset(offset)

    user_stmt = "select id from viusers where uname = ? limit 1"
    repls.where("viuser_id = (#{user_stmt})", from_user) if from_user
    repls.where("touser_id = (#{user_stmt})", to_user) if to_user

    render_repls(repls, pg_no)
  end

  @[AC::Route::GET("/thread/:urn")]
  def thread(urn : String, sort : String = "-id")
    pg_no, limit, offset = _paginate(min: 50, max: 2000)

    repls = Murepl.query.where("id > 0").sort_by(sort)
    repls.where("muhead_id = (select id from muheads where urn = ?)", urn)
    repls.limit(limit).offset(offset)

    render_repls(repls, pg_no)
  end

  @[AC::Route::GET("/tagged")]
  def tagged
    pg_no, limit, offset = _paginate(min: 10)

    repls = Murepl.query.where("id > 0").order_by(id: :desc)
    repls.where("(to_viuser_id = ? OR ? = any(tagged_ids)", _vu_id, _vu_id)

    # repls.with_cvpost
    repls.limit(limit).offset(offset)

    render_repls(repls, pg_no)
  end

  private def render_repls(repls : Enumerable(Murepl), pg_no = 1)
    user_ids = repls.map(&.viuser_id)
    user_ids << _vu_id if _vu_id >= 0

    users = Viuser.glob(user_ids)
    memos = Memoir.glob(_vu_id, :murepl, repls.map(&.id.to_i))

    render json: {
      pgidx: pg_no,
      repls: MureplView.as_list(repls),
      users: ViuserView.as_hash(users),
      memos: MemoirView.as_hash(memos),
    }
  end

  @[AC::Route::POST("/create", body: :form)]
  def create(form : MureplForm)
    guard_privi 0, "tạo bình luận"

    murepl = Murepl.new({
      viuser_id: _vu_id,
      muhead_id: Muhead.init!(form.muhead).id,
      touser_id: form.touser,
      torepl_id: form.torepl,
    })

    murepl.level = form.level
    murepl.update_content!(form.itext, persist: true)

    spawn Muhead.bump!(murepl.muhead_id)

    render json: MureplView.new(murepl)
  end

  @[AC::Route::GET("/edit/:repl_id")]
  def edit(repl_id : Int32)
    murepl = Murepl.load!(repl_id)

    render json: {
      id:    murepl.id,
      itext: murepl.itext,

      muhead: "id:#{murepl.muhead_id}",
      touser: murepl.touser_id,
      torepl: murepl.torepl_id,
    }
  rescue err
    render :not_found, text: "Bài viết không tồn tại!"
  end

  @[AC::Route::PATCH("/:repl_id", body: :form)]
  def update(repl_id : Int32, form : MureplForm)
    murepl = Murepl.load!(repl_id)
    guard_owner murepl.viuser_id, 0, "sửa bình luận"

    murepl.update_content!(form.itext, persist: true)
    render json: MureplView.new(murepl)
  end

  @[AC::Route::DELETE("/:repl_id")]
  def delete(repl_id : Int32)
    murepl = Murepl.load!(repl_id)
    guard_owner murepl.viuser_id, 0, "xoá bình luận"

    murepl.update({
      id:         -murepl.id,
      deleted_at: Time.utc,
      deleted_by: _vu_id,
    })

    render json: {msg: "bình luận đã bị xoá"}
  end
end
