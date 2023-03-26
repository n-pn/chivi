require "../_ctrl_base"

class CV::CvreplCtrl < CV::BaseCtrl
  base "/_db/tposts"

  @[AC::Route::GET("/")]
  def index(sort : String = "-id", post_id : Int64? = nil, uname : String? = nil)
    query = Cvrepl.query.sort_by(sort)

    query.where("cvpost_id = ?", post_id) if post_id

    if uname
      query.where("viuser_id = (select id from viusers where uname = ? limit 1)", uname)
    end

    query.with_cvpost
    query.with_viuser

    items = query.to_a
    memos = UserRepl.glob(_viuser.id, _viuser.privi, items.map(&.id))

    repls = items.map do |x|
      CvreplView.new(x, false, memo: memos[x.id]?)
    end

    render json: repls
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

    render json: CvreplView.new(cvrepl)
  end

  @[AC::Route::PATCH("/:repl_id", body: :form)]
  def update(repl_id : Int64, form : CvreplForm)
    cvrepl = Cvrepl.load!(repl_id)
    guard_owner cvrepl.viuser_id, 0, "sửa bình luận"

    cvrepl.update_content!(form.input)
    render json: CvreplView.new(cvrepl)
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
