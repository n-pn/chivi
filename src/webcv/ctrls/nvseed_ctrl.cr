class CV::NvseedCtrl < CV::BaseCtrl
  def index
    nvseed = load_nvseed
    nvinfo = nvseed.nvinfo

    force = params["force"]? == "true" && _cvuser.privi >= 0
    nvseed.refresh!(force: true) if force && nvseed.staled?(_cvuser.privi, force)

    send_json({chseed: nvinfo.nvseeds.to_a.map { |x| ChseedView.new(x) }})
  end

  def show
    nvseed = load_nvseed
    bseeds = nvseed.nvinfo.nvseeds.to_a.sort_by!(&.zseed)

    force = _cvuser.privi >= 0 && params["force"]? == "true"
    staled = nvseed.staled?(_cvuser.privi, force)
    nvseed.refresh!(force: true) if force && staled

    total = nvseed.chap_count
    pgidx = params.fetch_int("pg", min: 1)

    send_json({
      nvseed: bseeds.map { |x| ChseedView.new(x) },
      chseed: ChseedView.new(nvseed),
      chpage: {
        sname: nvseed.sname,
        total: total,
        pgidx: pgidx,
        pgmax: CtrlUtil.pgmax(total, 32),
        lasts: nvseed.lastpg.to_a.map { |x| ChinfoView.new(x) },
        chaps: nvseed.chpage(pgidx - 1).map { |x| ChinfoView.new(x) },
        stime: nvseed.stime,
        stale: staled,
      },
    })
  end
end
