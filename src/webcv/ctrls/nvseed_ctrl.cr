class CV::NvseedCtrl < CV::BaseCtrl
  def index
    nvinfo = Nvinfo.load!(params["book"].to_i64)

    sname = params.fetch_str("sname", "union")
    nvseed = Nvseed.load!(nvinfo.id, SnameMap.map_int(sname))

    force = params["force"]? == "true" && _cvuser.privi >= 0
    nvseed.refresh!(force: force) if nvseed.staled?(_cvuser.privi, force)

    send_json({chseed: nvinfo.nvseeds.to_a.map { |x| ChseedView.new(x) }})
  end

  def show
    nvseed = load_nvseed
    bseeds = nvseed.nvinfo.nvseeds

    force = _cvuser.privi >= 0 && params["force"]? == "true"
    nvseed.refresh!(force: force) if nvseed.staled?(_cvuser.privi, force)

    total = nvseed.chap_count
    pgidx = params.fetch_int("pg", min: 1)

    send_json({
      nvseed: bseeds.to_a.sort_by!(&.zseed).map { |x| ChseedView.new(x) },
      chseed: ChseedView.new(nvseed),
      chpage: {
        sname: nvseed.sname,
        total: total,
        pgidx: pgidx,
        pgmax: CtrlUtil.pgmax(total, 32),
        lasts: nvseed.lastpg.to_a.map { |x| ChinfoView.new(x) },
        chaps: nvseed.chpage(pgidx - 1).map { |x| ChinfoView.new(x) },
      },
    })
  end

  private def load_nvseed
    nvinfo_id = params["book"].to_i64
    sname = params.fetch_str("sname", "union")
    Nvseed.load!(nvinfo_id, SnameMap.map_int(sname))
  end
end
