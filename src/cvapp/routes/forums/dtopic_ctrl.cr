require "../_ctrl_base"
require "./dtopic_form"

class CV::DtopicCtrl < CV::BaseCtrl
  base "/_db/topics"

  @[AC::Route::GET("/")]
  def index(lb dlabel : String? = nil, dboard : Int32? = nil, by user : String? = nil)
    pg_no, limit, offset = _paginate(max: 100)
    query = Dtopic.query.order_by(_sort: :desc)

    query.where("? = ANY(lslugs)", TextUtil.slugify(dlabel)) if dlabel
    query.where("nvinfo_id = ?", dboard) if dboard

    query.where(<<-SQL, user) if user
      viuser_id = (select id from viusers where uname = ? limit 1)
      SQL

    total = query.dup.limit(limit * 3 + offset).offset(0).count

    posts = query.with_nvinfo.limit(limit).offset(offset).to_a
    memos = Memoir.glob(_vu_id, :dtopic, posts.map(&.id))

    user_ids = posts.map(&.viuser_id)
    user_ids << _vu_id if _vu_id >= 0

    users = Viuser.preload(user_ids)

    render json: {
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),

      posts: DtopicView.as_list(posts, false),
      memos: MemoirView.as_hash(memos),
      users: ViuserView.as_hash(users),
    }
  end

  @[AC::Route::POST("/", body: :form)]
  def create(b_id : Int32, form : DtopicForm)
    guard_privi 0, "tạo chủ đề"
    dboard = Wninfo.load!(b_id)

    dtopic = Dtopic.new({viuser_id: _viuser.id, nvinfo_id: dboard.id})
    dtopic.update_content!(form)
    spawn Rproot.new(dtopic).upsert!

    spawn do
      # TODO: directly call sql
      count = dboard.post_count &+ 1
      dboard.update!({post_count: count, board_bump: dtopic.utime})
    end

    render json: DtopicView.new(dtopic)
  end

  @[AC::Route::GET("/:post_id")]
  def show(post_id : Int32)
    cvpost = Dtopic.load!(post_id)
    cvpost.bump_view_count!

    viuser = Viuser.load!(cvpost.viuser_id)
    memoir = Memoir.load(_vu_id, :dtopic, cvpost.id)

    render json: {
      post: DtopicView.new(cvpost, full: true),
      user: ViuserView.new(viuser),
      memo: MemoirView.new(memoir),
    }
  rescue err
    render :not_found, text: "Chủ đề không tồn tại!"
  end

  @[AC::Route::GET("/form")]
  def edit(id dt_id : Int32 = 0, tb tb_id : Int32 = 0)
    if dt_id != 0
      dtopic = Dtopic.load!(dt_id)
      dboard = Wninfo.load!(dtopic.nvinfo_id)
    else
      dboard = Wninfo.load!(tb_id)
    end

    render json: {
      dtform: init_form(dtopic),
      dboard: {
        id:    dboard.id,
        bname: dboard.vname,
        bslug: dboard.bslug,
      },
    }
  rescue err
    render :not_found, text: "Chủ đề không tồn tại!"
  end

  private def init_form(dtopic : Dtopic)
    {id: dtopic.id, title: dtopic.title, btext: dtopic.btext, labels: dtopic.labels.join(",")}
  end

  private def init_form(dtopic : Nil)
    {id: 0, title: "", btext: "", labels: "Thảo luận"}
  end

  @[AC::Route::PATCH("/:post_id", body: :form)]
  def update(post_id : Int32, form : DtopicForm)
    cvpost = Dtopic.load!(post_id)
    guard_owner cvpost.viuser_id, 0, "sửa chủ đề"

    cvpost.update_content!(form)
    render json: DtopicView.new(cvpost)
  end

  @[AC::Route::DELETE("/:post_id")]
  def delete(post_id : Int32)
    cvpost = Dtopic.load!(post_id)
    guard_owner cvpost.viuser_id, 0, "xoá chủ đề"

    is_admin = _privi > 3 && _vu_id != cvpost.viuser_id
    cvpost.soft_delete(admin: is_admin)

    render json: {msg: "chủ đề đã bị xoá"}
  end
end
