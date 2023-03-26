require "../_ctrl_base"
require "./cvpost_form"

class CV::CvpostCtrl < CV::BaseCtrl
  base "/_db/topics"

  @[AC::Route::GET("/")]
  def index(
    labels : String? = nil,
    dboard : Int64? = nil,
    viuser : String? = nil
  )
    pgidx, limit, offset = _paginate(max: 100)

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
    query.with_lastrp(&.with_viuser)

    items = query.limit(limit).offset(offset).to_a
    memos = UserPost.glob(_viuser.id, _viuser.privi, items.map(&.id))

    render json: {
      dtlist: {
        total: total,
        pgidx: pgidx,
        pgmax: _pgidx(total, limit),
        items: items.map { |x|
          x.nvinfo = nvinfo if nvinfo
          x.viuser = viuser if viuser
          CvpostView.new(x, full: false, memo: memos[x.id]?)
        },
      },
    }
  end

  @[AC::Route::POST("/", body: :form)]
  def create(dboard : Int64, form : CvpostForm)
    guard_privi 0, "tạo chủ đề"
    nvinfo = Nvinfo.load!(dboard)

    count = nvinfo.post_count + 1
    cvpost = Cvpost.new({viuser_id: _viuser.id, nvinfo: nvinfo, ii: nvinfo.dt_ii + count})

    cvpost.update_content!(form)
    nvinfo.update!({post_count: count, board_bump: cvpost.utime})

    render json: {cvpost: CvpostView.new(cvpost)}
  end

  @[AC::Route::GET("/:post_id")]
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

  @[AC::Route::GET("/:post_id/detail")]
  def detail(post_id : Int64)
    cvpost = Cvpost.load!(post_id)

    render json: {
      id:     cvpost.oid,
      title:  cvpost.title,
      btext:  cvpost.btext,
      labels: cvpost.labels.join(","),
    }
  rescue err
    render :not_found, text: "Chủ đề không tồn tại!"
  end

  @[AC::Route::POST("/:post_id", body: :form)]
  def update(post_id : Int64, form : CvpostForm)
    cvpost = Cvpost.load!(post_id)
    guard_owner cvpost.viuser_id, 0, "sửa chủ đề"

    cvpost.update_content!(form)
    render json: {cvpost: CvpostView.new(cvpost)}
  end

  @[AC::Route::DELETE("/:post_id")]
  def delete(post_id : Int64)
    cvpost = Cvpost.load!(post_id)
    guard_owner cvpost.viuser_id, 0, "xoá chủ đề"

    is_admin = _privi > 3 && _vu_id != cvpost.viuser_id
    cvpost.soft_delete(admin: is_admin)

    render json: {msg: "chủ đề đã bị xoá"}
  end
end
