require "../_ctrl_base"

class CV::CvpostCtrl < CV::BaseCtrl
  base "/api/topics"

  @[AC::Route::GET("/")]
  def index(pg pgidx : Int32 = 1,
            lm limit : Int32 = 24,
            labels : String? = nil,
            dboard : Int64? = nil,
            viuser : String? = nil)
    offset = CtrlUtil.offset(pgidx, limit)

    query = Cvpost.query.order_by(_sort: :desc)

    query.where("state >= -1")
    query.filter_label(labels) if labels

    if nvinfo = dboard.try { |x| Nvinfo.load!(x) }
      query.filter_board(nvinfo)
    else
      query.where("_sort > 0")
    end

    if viuser = viuser && Viuser.load!(viuser)
      query.filter_owner(viuser)
    end

    total = query.dup.limit(limit * 3 + offset).offset(0).count

    query.with_nvinfo unless nvinfo
    query.with_viuser unless viuser
    query.with_rpbody.with_lastrp(&.with_viuser)

    items = query.limit(limit).offset(offset).to_a
    memos = UserPost.glob(_viuser.id, _viuser.privi, items.map(&.id))

    render json: {
      dtlist: {
        total: total,
        pgidx: pgidx,
        pgmax: CtrlUtil.pgmax(pgidx, total),
        items: items.map { |x|
          x.nvinfo = nvinfo if nvinfo
          x.viuser = viuser if viuser
          CvpostView.new(x, full: false, memo: memos[x.id]?)
        },
      },
    }
  end

  @[AC::Route::POST("/")]
  def create(dboard : Int64)
    nvinfo = Nvinfo.load!(dboard)

    unless _viuser.can?(:create_post)
      raise Unauthorized.new("Bạn không có quyền tạo chủ đề")
    end

    count = nvinfo.post_count + 1
    cvpost = Cvpost.new({viuser_id: _viuser.id, nvinfo: nvinfo, ii: nvinfo.dt_ii + count})

    cvpost.update_content!(params)
    nvinfo.update!({post_count: count, board_bump: cvpost.utime})

    render json: {cvpost: CvpostView.new(cvpost)}
  end

  @[AC::Route::GET("/:post_id", converters: {post_id: ConvertBase32})]
  def show(post_id : Int64)
    cvpost = Cvpost.load!(post_id)

    cvpost.bump_view_count!
    cvpost.nvinfo.tap { |x| x.update!(view_count: x.view_count + 1) }

    # TODO: load user trace

    if _viuser.privi >= 0
      memo = UserPost.find({viuser_id: _viuser.id, cvpost_id: cvpost.id})
    end

    render json: {cvpost: CvpostView.new(cvpost, full: true, memo: memo)}
  rescue err
    render :not_found, text: "Chủ đề không tồn tại!"
  end

  @[AC::Route::GET("/:post_id/detail", converters: {post_id: ConvertBase32})]
  def detail(post_id : Int64)
    cvpost = Cvpost.load!(post_id)

    render json: {
      id:     cvpost.oid,
      title:  cvpost.title,
      labels: cvpost.labels.join(","),

      body_input: cvpost.rpbody.input,
      body_itype: cvpost.rpbody.itype,
    }
  rescue err
    render :not_found, text: "Chủ đề không tồn tại!"
  end

  @[AC::Route::POST("/:post_id", converters: {post_id: ConvertBase32})]
  def update(post_id : Int64)
    cvpost = Cvpost.load!(post_id)

    unless _viuser.can?(cvpost.id, :level0)
      raise Unauthorized.new("Bạn không có quyền sửa chủ đề")
    end

    cvpost.update_content!(params)
    render json: {cvpost: CvpostView.new(cvpost)}
  end

  @[AC::Route::DELETE("/:post_id", converters: {post_id: ConvertBase32})]
  def delete(post_id : Int64)
    cvpost = Cvpost.load!(post_id)

    if _viuser.privi == cvpost.viuser_id
      admin = false
    elsif _viuser.privi > 2
      admin = true
    else
      raise Unauthorized.new("Bạn không có quyền xoá chủ đề")
    end

    cvpost.soft_delete(admin: admin)
    render json: {msg: "Chủ đề đã bị xoá"}
  end
end
