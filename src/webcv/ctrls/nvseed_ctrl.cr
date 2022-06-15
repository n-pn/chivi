class CV::NvseedCtrl < CV::BaseCtrl
  def index
    nslist = load_nvinfo.nvseeds.to_a.uniq!(&.sname).sort_by!(&.zseed)
    serv_json(nslist.map { |x| NvseedView.new(x) })
  end

  def show
    nvseed = load_nvseed
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
    nvseed = load_nvseed
    pgidx = params.fetch_int("page", min: 1)
    chaps = nvseed.chpage(pgidx - 1)

    serv_json({
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(nvseed.chap_count, 32),
      chaps: ChinfoView.list(chaps),
    })
  end

  def patch
    sname = params["sname"]
    raise Unauthorized.new("Bạn không đủ quyền hạn") unless can_patch_seed?(sname)

    nvseed = load_nvseed(sname)
    target = Nvseed.load!(nvseed.nvinfo, params["o_sname"])

    chmin = params.fetch_int("chmin", min: 1)
    chmax = params.fetch_int("chmax", min: chmin, max: target.chap_count)

    i_chmin = params.fetch_int("i_chmin")
    offset = i_chmin &- chmin

    nvseed.clone_range!(target, chmin, chmax, offset)
    nvseed.save!

    serv_json({from: i_chmin})
  end

  def can_patch_seed?(sname : String)
    case sname = params["sname"]
    when .starts_with?('=') then _cvuser.privi > 1
    when .starts_with?('@')
      return false if sname != '@' + _cvuser.uname
      _cvuser.privi - 1
    else
      false
    end
  end
end
