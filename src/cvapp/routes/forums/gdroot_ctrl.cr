require "../_ctrl_base"

class CV::GdrootCtrl < CV::BaseCtrl
  base "/_db/gdroots"

  @[AC::Route::GET("/show/:ruid")]
  def thread(ruid : String, sort : String = "-id")
    gdroot = Gdroot.load!(ruid)

    pg_no, limit, offset = _paginate(min: 50, max: 2000)

    repls = Rpnode.query.where("id > 0").sort_by(sort)
    repls.where("gdroot_id = ?", gdroot.id)

    repls.limit(limit).offset(offset)

    user_ids = repls.map(&.viuser_id)
    user_ids << _vu_id if _vu_id >= 0

    users = Viuser.preload(user_ids)
    memos = Memoir.glob(_vu_id, :rpnode, repls.map(&.id.to_i))

    render json: {
      gdroot: GdrootView.new(gdroot),

      rplist: {
        pgidx: pg_no,
        repls: RpnodeView.as_list(repls),
        users: ViuserView.as_hash(users),
        memos: MemoirView.as_hash(memos),
      },
    }
  end
end
