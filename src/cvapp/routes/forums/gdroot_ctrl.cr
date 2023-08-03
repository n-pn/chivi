require "../_ctrl_base"

class CV::GdrootCtrl < CV::BaseCtrl
  base "/_db/droots"

  @[AC::Route::GET("/show/:ruid")]
  def thread(ruid : String, sort : String = "-id")
    gdroot = Gdroot.load!(ruid)

    pg_no, limit, offset = _paginate(min: 50, max: 9999)
    repls = GdreplCard.by_thread(gdroot.id!, _vu_id, limit, offset)

    render json: {
      gdroot: GdrootView.new(gdroot),
      rplist: {repls: repls, pgidx: pg_no, total: gdroot.repl_count},
    }
  end
end
