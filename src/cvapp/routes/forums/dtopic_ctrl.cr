require "../_ctrl_base"
require "./dtopic_form"

class CV::DtopicCtrl < CV::BaseCtrl
  base "/_db/topics"

  @[AC::Route::GET("/")]
  def index(lb labels : String? = nil, dboard : Int64? = nil, viuser : String? = nil)
    pgidx, limit, offset = _paginate(max: 100)

    query = Dtopic.query.order_by(_sort: :desc)

    query.where("state >= -1")
    query.filter_label(labels) if labels

    if nvinfo = dboard.try { |x| Wninfo.load!(x) }
      query.filter_board(nvinfo)
    end

    if viuser
      query.where("viuser_id = (select id from viusers where uname = ? limit 1)", viuser)
    end

    total = query.dup.limit(limit * 3 + offset).offset(0).count

    query.with_nvinfo unless nvinfo

    posts = query.limit(limit).offset(offset).to_a
    memos = Memoir.glob(_vu_id, :dtopic, posts.map(&.id.to_i))

    user_ids = posts.map(&.viuser_id)
    user_ids << _vu_id if _vu_id >= 0

    users = Viuser.glob(user_ids)

    posts.map(&.nvinfo = nvinfo) if nvinfo

    render json: {
      total: total,
      pgidx: pgidx,
      pgmax: _pgidx(total, limit),

      posts: DtopicView.as_list(posts, false),
      memos: MemoirView.as_hash(memos),
      users: ViuserView.as_hash(users),
    }
  end

  @[AC::Route::POST("/", body: :form)]
  def create(dboard : Int64, form : DtopicForm)
    guard_privi 0, "tạo chủ đề"
    nvinfo = Wninfo.load!(dboard)

    count = nvinfo.post_count + 1
    cvpost = Dtopic.new({viuser_id: _viuser.id, nvinfo: nvinfo, ii: nvinfo.dt_ii + count})

    cvpost.update_content!(form)
    nvinfo.update!({post_count: count, board_bump: cvpost.utime})

    render json: {cvpost: DtopicView.new(cvpost)}
  end

  @[AC::Route::GET("/:post_id")]
  def show(post_id : Int64)
    cvpost = Dtopic.load!(post_id)
    cvpost.bump_view_count!

    viuser = Viuser.load!(cvpost.viuser_id)
    memoir = Memoir.load(_vu_id, :dtopic, cvpost.id.to_i)

    render json: {
      post: DtopicView.new(cvpost, full: true),
      user: ViuserView.new(viuser),
      memo: MemoirView.new(memoir),
    }
  rescue err
    render :not_found, text: "Chủ đề không tồn tại!"
  end

  @[AC::Route::GET("/:post_id/detail")]
  def detail(post_id : Int64)
    cvpost = Dtopic.load!(post_id)

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
  def update(post_id : Int64, form : DtopicForm)
    cvpost = Dtopic.load!(post_id)
    guard_owner cvpost.viuser_id, 0, "sửa chủ đề"

    cvpost.update_content!(form)
    render json: {cvpost: DtopicView.new(cvpost)}
  end

  @[AC::Route::DELETE("/:post_id")]
  def delete(post_id : Int64)
    cvpost = Dtopic.load!(post_id)
    guard_owner cvpost.viuser_id, 0, "xoá chủ đề"

    is_admin = _privi > 3 && _vu_id != cvpost.viuser_id
    cvpost.soft_delete(admin: is_admin)

    render json: {msg: "chủ đề đã bị xoá"}
  end
end
