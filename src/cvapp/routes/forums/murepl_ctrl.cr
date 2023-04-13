require "../_ctrl_base"

class CV::MureplCtrl < CV::BaseCtrl
  base "/_db/mrepls"

  @[AC::Route::GET("/")]
  def index(sort : String = "-id",
            from from_user : String? = nil, to to_user : String? = nil,
            memo : String? = nil)
    repls = Murepl.query.where("id > 0").sort_by(sort)

    pg_no, limit, offset = _paginate(min: 20, max: 100)
    repls.limit(limit).offset(offset)

    user_stmt = "select id from viusers where uname = ? limit 1"
    repls.where("viuser_id = (#{user_stmt})", from_user) if from_user
    repls.where("to_viuser_id = (#{user_stmt})", to_user) if to_user

    # repls.with_cvpost

    render_repls(repls, pg_no)
  end

  @[AC::Route::GET("/thread/:id/:mu")]
  def thread(id thread : Int32, mu mutype : Int16, sort : String = "-id")
    repls = Murepl.query.where("id > 0").sort_by(sort)

    pg_no, limit, offset = _paginate(min: 50, max: 2000)
    repls.limit(limit).offset(offset)

    repls.where("(thread_id = ? and thread_mu = ?)", thread, mutype)
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

  struct MureplForm
    include JSON::Serializable

    getter itext : String
    getter level : Int16 = 0_i16

    getter thread_id : Int32 = 0
    getter thread_mu : Int16 = 0_i16

    getter torepl_id : Int32 = 0
    getter touser_id : Int32 = 0

    def after_initialize
      @itext = @itext.strip
      @level = 0 if @level < 0
    end

    def valid?
      raise "Độ dài nội dung quá ngắn" if @itext.size < 3
    end
  end

  @[AC::Route::POST("/create", body: :form)]
  def create(form : MureplForm)
    guard_privi 0, "tạo bình luận"

    murepl = Murepl.new({
      viuser_id: _vu_id,
      thread_id: form.thread_id,
      thread_mu: form.thread_mu,
      touser_id: form.touser_id,
      torepl_id: form.torepl_id,
    })

    murepl.level = form.level
    murepl.update_content!(form.itext, persist: true)

    spawn murepl.bump_parent_on_create!

    render json: MureplView.new(murepl)
  end

  @[AC::Route::GET("/edit/:repl_id")]
  def edit(repl_id : Int32)
    murepl = Murepl.load!(repl_id)

    render json: {
      id:    murepl.id,
      itext: murepl.itext,

      thread_id: murepl.thread_id,
      thread_mu: murepl.thread_mu,

      touser_id: murepl.touser_id,
      torepl_id: murepl.torepl_id,
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
