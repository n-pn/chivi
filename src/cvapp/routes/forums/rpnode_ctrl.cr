require "../_ctrl_base"
require "./murepl_form"

class CV::RpnodeCtrl < CV::BaseCtrl
  base "/_db/mrepls"

  # @[AC::Route::GET("/")]
  # def index(sort : String = "-id",
  #           from from_user : String? = nil, to to_user : String? = nil,
  #           self memo : String? = nil)
  #   repls = Rpnode.query.where("id > 0").sort_by(sort)

  #   pg_no, limit, offset = _paginate(min: 20, max: 100)
  #   repls.limit(limit).offset(offset)

  #   user_stmt = "select id from viusers where uname = ? limit 1"
  #   repls.where("viuser_id = (#{user_stmt})", from_user) if from_user
  #   repls.where("touser_id = (#{user_stmt})", to_user) if to_user

  #   render_repls(repls, pg_no, multi_heads: true)
  # end

  @[AC::Route::GET("/thread/:urn")]
  def thread(urn : String, sort : String = "-id")
    pg_no, limit, offset = _paginate(min: 50, max: 2000)

    repls = Rpnode.query.where("id > 0").sort_by(sort)
    repls.where("muhead_id = (select id from muheads where urn = ?)", urn)
    repls.limit(limit).offset(offset)

    render_repls(repls, pg_no, multi_heads: false)
  end

  # @[AC::Route::GET("/tagged")]
  # def tagged
  #   pg_no, limit, offset = _paginate(min: 10)

  #   repls = Rpnode.query.where("id > 0").order_by(id: :desc)
  #   repls.where("(to_viuser_id = ? OR ? = any(tagged_ids)", _vu_id, _vu_id)

  #   # repls.with_cvpost
  #   repls.limit(limit).offset(offset)
  #   render_repls(repls, pg_no, multi_heads: true)
  # end

  private def render_repls(repls : Enumerable(Rpnode), pg_no = 1, multi_heads = false)
    user_ids = repls.map(&.viuser_id)
    user_ids << _vu_id if _vu_id >= 0

    users = Viuser.preload(user_ids)
    memos = Memoir.glob(_vu_id, :rpnode, repls.map(&.id.to_i))

    # heads = glob_heads(repls, multi_heads: multi_heads)

    render json: {
      pgidx: pg_no,
      repls: RpnodeView.as_list(repls),
      # heads: RprootView.as_hash(heads),
      users: ViuserView.as_hash(users),
      memos: MemoirView.as_hash(memos),
    }
  end

  private def glob_heads(repls : Enumerable(Rpnode), multi_heads = false)
    if repls.empty?
      [] of Rproot
    elsif multi_heads
      Rproot.glob(repls.map(&.muhead_id).uniq!)
    else
      [Rproot.find!(repls.first!.muhead_id)]
    end
  end

  @[AC::Route::POST("/create", body: :form)]
  def create(form : RpnodeForm)
    guard_privi 0, "tạo bình luận"

    rpnode = Rpnode.new({
      viuser_id: _vu_id,
      muhead_id: Rproot.init!(form.muhead).id,
      touser_id: form.touser,
      torepl_id: form.torepl,
    })

    rpnode.level = form.level
    rpnode.update_content!(form.itext, persist: true)

    spawn Rproot.bump!(rpnode.muhead_id)
    spawn Notifier.on_user_making_reply(rpnode)
    spawn Notifier.on_user_tagged_in_reply(rpnode)

    render json: RpnodeView.new(rpnode)
  end

  @[AC::Route::GET("/edit/:repl_id")]
  def edit(repl_id : Int32)
    rpnode = Rpnode.load!(repl_id)

    render json: {
      id:    rpnode.id,
      itext: rpnode.itext,

      muhead: "id:#{rpnode.muhead_id}",
      touser: rpnode.touser_id,
      torepl: rpnode.torepl_id,
    }
  rescue err
    render :not_found, text: "Bài viết không tồn tại!"
  end

  @[AC::Route::PATCH("/:repl_id", body: :form)]
  def update(repl_id : Int32, form : RpnodeForm)
    rpnode = Rpnode.load!(repl_id)
    guard_owner rpnode.viuser_id, 0, "sửa bình luận"

    rpnode.update_content!(form.itext, persist: true)
    spawn Notifier.on_user_tagged_in_reply(rpnode)

    render json: RpnodeView.new(rpnode)
  end

  @[AC::Route::DELETE("/:repl_id")]
  def delete(repl_id : Int32)
    murepl = Rpnode.load!(repl_id)
    guard_owner murepl.viuser_id, 0, "xoá bình luận"

    murepl.update({
      id:         -murepl.id,
      deleted_at: Time.utc,
      deleted_by: _vu_id,
    })

    render json: {msg: "bình luận đã bị xoá"}
  end
end
