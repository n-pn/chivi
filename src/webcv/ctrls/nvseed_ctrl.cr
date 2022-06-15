class CV::NvseedCtrl < CV::BaseCtrl
  private def load_nvinfo : Nvinfo
    nv_id = params["nv_id"].to_i64
    Nvinfo.load!(nv_id) || raise NotFound.new("Quyển sách không tồn tại")
  end

  private def load_nvseed
    sname = params["sname"]
    force = sname.in?("=base", "=user", "@#{_cvuser.uname}")
    Nvseed.load!(load_nvinfo, sname, force: force)
  end

  ##########

  def index
    nslist = load_nvinfo.nvseeds.to_a.uniq!(&.sname).sort_by!(&.zseed)
    serv_json(nslist.map { |x| NvseedView.new(x) })
  end

  def show
    nvseed = load_nvseed(params["sname"])
    mode = params.fetch_int("mode", 0)

    if mode > 0 && can_refresh?(nvseed)
      nvseed.refresh!(mode: mode)
      fresh = true
    else
      fresh = nvseed.fresh?(_cvuser.privi, force: false)
    end

    serv_json(NvseedView.new(nvseed, full: true, fresh: fresh))
  end

  private def can_refresh?(nvseed : Nvseed)
    return false if _cvuser.privi < 0
    return true unless nvseed.sname[0] == '@'
    nvseed.sname == '@' + _cvuser.uname
  end

  def chaps
    nvseed = load_nvseed(params["sname"])
    pgidx = params.fetch_int("page", min: 1)
    chaps = nvseed.chpage(pgidx - 1)

    serv_json({
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(nvseed.chap_count, 32),
      chaps: ChinfoView.list(chaps),
    })
  end
end
