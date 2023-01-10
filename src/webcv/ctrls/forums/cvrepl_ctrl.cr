require "../_ctrl_base"

class CV::CvreplCtrl < CV::BaseCtrl
  base "/api/tposts"

  @[AC::Route::GET("/", converters: {cvpost: ConvertBase32})]
  def index(pg pgidx : Int32 = 1,
            lm limit : Int32 = 24,
            sort : String = "id",
            cvpost post_id : Int64? = nil,
            viuser uname : String? = nil)
    offset = CtrlUtil.offset(pgidx, limit)

    query = Cvrepl.query.where("ii > 0")
    query.sort_by(sort)

    if cvpost = post_id && Cvpost.load!(post_id)
      query.where("cvpost_id = ?", cvpost.id)
    end

    if viuser = uname && Viuser.load!(uname)
      query.where("viuser_id = ?", viuser.id)
    end

    if cvpost
      total = cvpost.repl_count
    else
      total = query.dup.limit(limit * 3 + offset).offset(0).count
    end

    query.with_cvpost unless cvpost
    query.with_viuser unless viuser
    items = query.limit(limit).offset(offset).to_a
    memos = UserRepl.glob(_viuser.id, _viuser.privi, items.map(&.id))

    {
      tplist: {
        total: total,
        pgidx: pgidx,
        pgmax: (total - 1) // limit + 1,
        items: items.map do |x|
          x.viuser = viuser if viuser
          x.cvpost = cvpost if cvpost
          CvreplView.new(x, false, memo: memos[x.id]?)
        end,
      },
    }
  end

  @[AC::Route::GET("/:repl_id/detail")]
  def detail(repl_id : Int64)
    cvrepl = Cvrepl.load!(repl_id)

    {
      id:    cvrepl.id,
      input: cvrepl.input,
      itype: cvrepl.itype,
      rp_id: cvrepl.repl_cvrepl_id,
    }
  rescue err
    render :not_found, text: "Bài viết không tồn tại!"
  end

  @[AC::Route::POST("/", converters: {cvpost: ConvertBase32})]
  def create(cvpost post_id : Int64)
    cvpost = Cvpost.load!(post_id)

    unless _viuser.can?(:create_post)
      raise Unauthorized.new "Bạn không có quyền tạo bình luận mới"
    end

    cvrepl = Cvrepl.new({viuser_id: _viuser.id, cvpost: cvpost, ii: cvpost.repl_count + 1})

    dtrepl_id = params["rp_id"]?.try(&.to_i64?) || 0_i64
    dtrepl_id = cvpost.rpbody.id if dtrepl_id == 0

    cvrepl.set_dtrepl_id(dtrepl_id)
    cvrepl.update_content!(params)
    cvpost.bump!(cvrepl.id)

    repl = Cvrepl.load!(cvrepl.repl_cvrepl_id)
    repl.update!({repl_count: repl.repl_count + 1})

    {cvrepl: CvreplView.new(cvrepl)}
  end

  @[AC::Route::POST("/:repl_id")]
  def update(repl_id : Int64)
    cvrepl = Cvrepl.load!(repl_id)

    unless _viuser.can?(cvrepl.viuser_id, :update_post)
      raise Unauthorized.new "Bạn không có quyền sửa bình luận"
    end

    cvrepl.update_content!(params)
    {cvrepl: CvreplView.new(cvrepl)}
  end

  @[AC::Route::DELETE("/:repl_id")]
  def delete(repl_id : Int64)
    cvrepl = Cvrepl.load!(repl_id)

    if _viuser.privi == cvrepl.viuser_id
      admin = false
    elsif _viuser.privi > 2
      admin = true
    else
      raise Unauthorized.new "Bạn không có quyền xoá bình luận"
    end

    cvrepl.soft_delete(admin: admin)
    {msg: "ok"}
  end
end
