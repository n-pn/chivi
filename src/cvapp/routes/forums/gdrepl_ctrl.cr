require "../_ctrl_base"
require "./gdrepl_form"

class CV::GdreplCtrl < CV::BaseCtrl
  base "/_db/mrepls"

  @[AC::Route::GET("/")]
  def index(sort : String = "-id",
            from from_user : String? = nil, to to_user : String? = nil,
            self memo : String? = nil)
    repls = Gdrepl.query.where("id > 0").sort_by(sort)

    pg_no, limit, offset = _paginate(min: 20, max: 100)
    repls.limit(limit).offset(offset)

    user_stmt = "select id from viusers where uname = ? limit 1"
    repls.where("viuser_id = (#{user_stmt})", from_user) if from_user
    repls.where("touser_id = (#{user_stmt})", to_user) if to_user

    render_repls(repls, pg_no, multi_heads: true)
  end

  # @[AC::Route::GET("/tagged")]
  # def tagged
  #   pg_no, limit, offset = _paginate(min: 10)

  #   repls = Gdrepl.query.where("id > 0").order_by(id: :desc)
  #   repls.where("(to_viuser_id = ? OR ? = any(tagged_ids)", _vu_id, _vu_id)

  #   # repls.with_cvpost
  #   repls.limit(limit).offset(offset)
  #   render_repls(repls, pg_no, multi_heads: true)
  # end

  private def render_repls(repls : Enumerable(Gdrepl), pg_no = 1, multi_heads = false)
    user_ids = repls.map(&.viuser_id)
    user_ids << _vu_id if _vu_id >= 0

    users = Viuser.preload(user_ids)
    memos = Memoir.glob(_vu_id, :gdrepl, repls.map(&.id.to_i))

    # heads = glob_heads(repls, multi_heads: multi_heads)

    render json: {
      pgidx: pg_no,
      repls: GdreplView.as_list(repls),
      # heads: GdrootView.as_hash(heads),
      users: ViuserView.as_hash(users),
      memos: MemoirView.as_hash(memos),
    }
  end

  private def glob_heads(repls : Enumerable(Gdrepl), multi_heads = false)
    if repls.empty?
      [] of Gdroot
    elsif multi_heads
      Gdroot.glob(repls.map(&.gdroot_id).uniq!)
    else
      [Gdroot.find!(repls.first!.gdroot_id)]
    end
  end

  @[AC::Route::POST("/create", body: :form)]
  def create(form : GdreplForm)
    guard_privi 0, "tạo bình luận"

    rpnode = Gdrepl.new({
      viuser_id: _vu_id,
      gdroot_id: Gdroot.load!(form.gdroot).id,
      touser_id: form.touser,
      torepl_id: form.torepl,
    })

    rpnode.level = form.level
    rpnode.update_content!(form.itext, persist: true)

    spawn Gdroot.bump_on_new_reply!(rpnode.gdroot_id)
    spawn Notifier.on_repl_event(rpnode)

    render json: GdreplView.new(rpnode)
  end

  @[AC::Route::GET("/edit/:repl_id")]
  def edit(repl_id : Int32)
    rpnode = Gdrepl.load!(repl_id)

    render json: {
      id:    rpnode.id,
      itext: rpnode.itext,

      gdroot: "id:#{rpnode.gdroot_id}",
      touser: rpnode.touser_id,
      torepl: rpnode.torepl_id,
    }
  rescue err
    render :not_found, text: "Bài viết không tồn tại!"
  end

  @[AC::Route::PATCH("/:repl_id", body: :form)]
  def update(repl_id : Int32, form : GdreplForm)
    rpnode = Gdrepl.load!(repl_id)
    guard_owner rpnode.viuser_id, 0, "sửa bình luận"

    rpnode.update_content!(form.itext, persist: true)
    spawn Notifier.on_tagged_in_reply(rpnode)

    render json: GdreplView.new(rpnode)
  end

  @[AC::Route::DELETE("/:repl_id")]
  def delete(repl_id : Int32)
    rpnode = Gdrepl.load!(repl_id)
    guard_owner rpnode.viuser_id, 0, "xoá bình luận"

    rpnode.update({deleted_at: Time.utc, deleted_by: _vu_id})
    render json: {msg: "bình luận đã bị xoá"}
  end
end
