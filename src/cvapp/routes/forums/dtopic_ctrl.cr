require "../_ctrl_base"
require "./dtopic_form"

class CV::DtopicCtrl < CV::BaseCtrl
  base "/_db/topics"

  @[AC::Route::GET("/")]
  def index(lb label : String? = nil, dboard : Int32? = nil, by vuser : String? = nil)
    pg_no, limit, offset = _paginate(max: 100)
    label = TextUtil.slugify(label) if label

    total, posts = DtopicCard.fetch_all(
      _memo: _vu_id,
      board: dboard, vuser: vuser,
      label: label,
      limit: limit, offset: offset,
    )

    render json: {
      posts: posts,
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end

  @[AC::Route::POST("/", body: :form)]
  def create(b_id : Int32, form : DtopicForm)
    guard_privi 0, "tạo chủ đề"
    dboard = Wninfo.load!(b_id)

    dtopic = Dtopic.new({viuser_id: _viuser.id, nvinfo_id: dboard.id})
    dtopic.update_content!(form)

    spawn do
      # TODO: directly call sql
      count = dboard.post_count &+ 1
      dboard.update!({post_count: count, board_bump: dtopic.utime})

      Gdroot.new(:dtopic, dtopic.id.to_s).init_from(dtopic).upsert!
    end

    render text: "#{dtopic.id}-#{dtopic.tslug}"
  end

  @[AC::Route::GET("/:post_id")]
  def show(post_id : Int32)
    spawn DtopicCard.inc_counter(post_id, "view_count", 1)
    render json: DtopicCard.fetch_one(post_id, _vu_id)
  rescue ex
    Log.error(exception: ex) { post_id.colorize.red }
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
        bname: dboard.btitle_vi,
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
    dtopic = Dtopic.load!(post_id)
    guard_owner dtopic.viuser_id, 0, "sửa chủ đề"

    dtopic.update_content!(form)
    render text: "#{dtopic.id}-#{dtopic.tslug}"
  end

  @[AC::Route::DELETE("/:post_id")]
  def delete(post_id : Int32)
    dtopic = Dtopic.load!(post_id)
    guard_owner dtopic.viuser_id, 0, "xoá chủ đề"

    is_admin = _privi > 3 && _vu_id != dtopic.viuser_id
    dtopic.soft_delete(admin: is_admin)

    render json: {msg: "chủ đề đã bị xoá"}
  end
end
