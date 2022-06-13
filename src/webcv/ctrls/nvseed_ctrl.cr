class CV::NvseedCtrl < CV::BaseCtrl
  private def load_nvinfo(bslug = params["bslug"]) : Nvinfo
    Nvinfo.load!(bslug) || raise NotFound.new("Quyển sách #{bslug} không tồn tại")
  end

  private def load_nvseed(sname = params["sname"])
    nvinfo = load_nvinfo(params["bslug"])
    force = sname.in?("=base", "$user", "@#{_cvuser.uname}")
    Nvseed.load!(nvinfo, params["sname"], force: force)
  end

  ##########

  def index
    nvinfo = load_nvinfo(params["bslug"])
    nslist = nvinfo.nvseeds.to_a.uniq!(&.sname).sort_by!(&.zseed)

    serv_json(nslist.map { |x| NvseedView.new(x) })
  end

  def show
    nvseed = load_nvseed(params["sname"])

    force = params["force"]? == "true"
    fresh = nvseed.fresh?(_cvuser.privi, force: force)
    nvseed.refresh!(force: !fresh) if force

    serv_json(NvseedView.new(nvseed, full: true, fresh: fresh || force))
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
