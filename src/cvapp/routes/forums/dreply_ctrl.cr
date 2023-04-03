require "../_ctrl_base"

class CV::CvreplCtrl < CV::BaseCtrl
  base "/_db/tposts"

  @[AC::Route::GET("/")]
  def index(sort : String = "-id", post : Int64? = nil, uname : String? = nil)
    repls = Cvrepl.query.sort_by(sort)

    if post
      repls.where("cvpost_id = ?", post)
    end

    if uname
      repls.where("viuser_id = (select id from viusers where uname = ? limit 1)", uname)
    end

    repls.with_cvpost

    render_repls(repls)
  end

  @[AC::Route::GET("/tagged")]
  def tagged
    pg_no, limit, offset = _paginate(min: 10)

    repls = Cvrepl.query.order_by(id: :desc)
    repls.where("state >= 0 AND viuser_id != ?", _vu_id)
    repls.where("(repl_viuser_id = ? OR tagged_ids @> ?::bigint[])", _vu_id, [_vu_id])

    repls.with_cvpost
    repls.limit(limit).offset(offset)

    render_repls(repls, pg_no)
  end

  private def render_repls(repls : Enumerable(Cvrepl), pg_no = 1)
    user_ids = repls.map(&.viuser_id)
    user_ids << _vu_id if _vu_id >= 0

    users = Viuser.glob(user_ids)
    memos = Memoir.glob(_vu_id, :dreply, repls.map(&.id.to_i))

    render json: {
      pgidx: pg_no,
      repls: DreplyView.as_list(repls),
      users: ViuserView.as_hash(users),
      memos: MemoirView.as_hash(memos),
    }
  end

  @[AC::Route::GET("/:repl_id/detail")]
  def detail(repl_id : Int64)
    cvrepl = Cvrepl.load!(repl_id)

    render json: {
      id:    cvrepl.id,
      input: cvrepl.input,

      post_id: cvrepl.cvpost_id,
      repl_id: cvrepl.repl_cvrepl_id,
    }
  rescue err
    render :not_found, text: "Bài viết không tồn tại!"
  end

  record CvreplForm, input : String, repl_id : Int64 = 0, post_id : Int64 = 0 do
    include JSON::Serializable

    def after_initialize
      @input = @input.strip
      @repl_id = -@post_id if @repl_id == 0
    end
  end

  @[AC::Route::POST("/", body: :form)]
  def create(form : CvreplForm)
    guard_privi 0, "tạo bình luận"

    cvpost = Cvpost.load!(form.post_id)
    cvrepl = Cvrepl.new({viuser_id: _vu_id, cvpost: cvpost})

    cvrepl.set_dtrepl_id(form.repl_id)
    cvrepl.update_content!(form.input)
    cvpost.bump!(cvrepl.id)

    render json: DreplyView.new(cvrepl)
  end

  @[AC::Route::PATCH("/:repl_id", body: :form)]
  def update(repl_id : Int64, form : CvreplForm)
    cvrepl = Cvrepl.load!(repl_id)
    guard_owner cvrepl.viuser_id, 0, "sửa bình luận"

    cvrepl.update_content!(form.input)
    render json: DreplyView.new(cvrepl)
  end

  @[AC::Route::DELETE("/:repl_id")]
  def delete(repl_id : Int64)
    cvrepl = Cvrepl.load!(repl_id)
    guard_owner cvrepl.viuser_id, 0, "xoá bình luận"

    is_admin = _privi > 3 && _vu_id != cvrepl.viuser_id
    cvrepl.soft_delete(admin: is_admin)

    render json: {msg: "bình luận đã bị xoá"}
  end
end
