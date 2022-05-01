require "./_base_ctrl"

class CV::NvseedCtrl < CV::BaseCtrl
  def index
    nvinfo = Nvinfo.load!(params["book"].to_i64)

    sname = params.fetch_str("sname", "chivi")
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
    sname = params.fetch_str("sname", "chivi")
    Nvseed.load!(nvinfo_id, SnameMap.map_int(sname))
  end

  private def seed_outdated?(nvseed : Nvseed, privi = 0)
    tspan = Time.utc - Time.unix(nvseed.atime)
    bonus = 4 - privi

    case nvseed.status
    when 0 then tspan > 2.hours * bonus
    when 1 then tspan > 2.days * bonus
    when 2 then tspan > 2.weeks * bonus
    else        false
    end
  end
end
