require "../_ctrl_base"

class CV::CvreplCtrl < CV::BaseCtrl
  base "/_db/tposts"

  @[AC::Route::GET("/", converters: {post_id: ConvertBase32})]
  def index(sort : String = "id", post_id : Int64? = nil, uname : String? = nil)
    query = Cvrepl.query.where("ii > 0")
    query.sort_by(sort)

    if post_id
      query.where("cvpost_id = (select id from cvposts where ii = ? limit 1)", post_id)
    end

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
      itype: cvrepl.itype,
      rp_id: cvrepl.repl_cvrepl_id,
    }
  rescue err
    render :not_found, text: "Bài viết không tồn tại!"
  end

  record CvreplForm, input : String, rp_id : Int64 = 0 do
    include JSON::Serializable
  end

  @[AC::Route::POST("/", body: :form, converters: {post_id: ConvertBase32})]
  def create(post_id : Int64, form : CvreplForm)
    guard_privi 0, "tạo bình luận"
    cvpost = Cvpost.load!(post_id)

    cvrepl = Cvrepl.new({viuser_id: _viuser.id, cvpost: cvpost, ii: cvpost.repl_count + 1})

    dtrepl_id = form.rp_id == 0 ? -cvpost.id : form.rp_id

    cvrepl.set_dtrepl_id(dtrepl_id)
    cvrepl.update_content!(form.input)
    cvpost.bump!(cvrepl.id)

    repl = Cvrepl.load!(cvrepl.repl_cvrepl_id)
    repl.update!({repl_count: repl.repl_count + 1})

    render json: {cvrepl: CvreplView.new(cvrepl)}
  end

  @[AC::Route::POST("/:repl_id", body: :form)]
  def update(repl_id : Int64, form : CvreplForm)
    cvrepl = Cvrepl.load!(repl_id)
    guard_owner cvrepl.viuser_id, 0, "sửa bình luận"

    cvrepl.update_content!(form.input)
    render json: {cvrepl: CvreplView.new(cvrepl)}
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
