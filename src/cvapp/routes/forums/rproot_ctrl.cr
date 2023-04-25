require "../_ctrl_base"
require "./rpnode_form"

class CV::RprootCtrl < CV::BaseCtrl
  base "/_db/rproots"

  @[AC::Route::GET("/show/:ruid")]
  def thread(ruid : String, sort : String = "-id")
    rproot = Rproot.init!(ruid)

    pg_no, limit, offset = _paginate(min: 50, max: 2000)

    repls = Rpnode.query.where("id > 0").sort_by(sort)
    repls.where("rproot_id = ?", rproot.id)

    repls.limit(limit).offset(offset)

    user_ids = repls.map(&.viuser_id)
    user_ids << _vu_id if _vu_id >= 0

    users = Viuser.preload(user_ids)
    memos = Memoir.glob(_vu_id, :rpnode, repls.map(&.id.to_i))

    # heads = glob_heads(repls, multi_heads: multi_heads)

    render json: {
      rproot: RprootView.new(rproot),

      rplist: {
        pgidx: pg_no,
        repls: RpnodeView.as_list(repls),
        # heads: RprootView.as_hash(heads),
        users: ViuserView.as_hash(users),
        memos: MemoirView.as_hash(memos),
      },
    }
  end

  private def glob_heads(repls : Enumerable(Rpnode), multi_heads = false)
    if repls.empty?
      [] of Rproot
    elsif multi_heads
      Rproot.glob(repls.map(&.rproot_id).uniq!)
    else
      [Rproot.find!(repls.first!.rproot_id)]
    end
  end

  @[AC::Route::POST("/create", body: :form)]
  def create(form : RpnodeForm)
    guard_privi 0, "tạo bình luận"

    rpnode = Rpnode.new({
      viuser_id: _vu_id,
      rproot_id: Rproot.init!(form.rproot).id,
      touser_id: form.touser,
      torepl_id: form.torepl,
    })

    rpnode.level = form.level
    rpnode.update_content!(form.itext, persist: true)

    spawn Rproot.bump_on_new_reply!(rpnode.rproot_id)
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

      rproot: "id:#{rpnode.rproot_id}",
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
    rpnode = Rpnode.load!(repl_id)
    guard_owner rpnode.viuser_id, 0, "xoá bình luận"

    rpnode.update({deleted_at: Time.utc, deleted_by: _vu_id})
    render json: {msg: "bình luận đã bị xoá"}
  end
end
