class CV::NvseedCtrl < CV::BaseCtrl
  def index
    nslist = load_nvinfo.seed_list
    serv_json(NslistView.new(nslist))
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

  def create
    assert_privi 2

    nvinfo = load_nvinfo

    sname = params["sname"]
    snvid = params["snvid"]

    Nvseed.upsert!(nvinfo, sname, snvid, force: true)
    serv_json({sname: sname, snvid: snvid})
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

  getter nvseed : Nvseed { load_nvseed(params["sname"]) }

  before_action do
    only [:patch, :trunc, :prune] do
      sname = params["sname"]
      unless action_allowed?(sname)
        raise Unauthorized.new("Bạn không đủ quyền hạn")
      end

      @nvseed = load_nvseed(sname)
    end
  end

  private def action_allowed?(sname : String)
    privi = _cvuser.privi

    case sname
    when .starts_with?('=')
      privi > 1
    when .starts_with?('@')
      privi > 0 && sname == '@' + _cvuser.uname
    else
      false
    end
  end

  def patch
    nvseed = self.nvseed
    target = Nvseed.load!(nvseed.nvinfo, params["o_sname"])

    chmin = params.fetch_int("chmin", min: 1)
    chmax = params.fetch_int("chmax", min: chmin, max: target.chap_count)

    i_chmin = params.fetch_int("i_chmin")
    offset = i_chmin &- chmin

    nvseed.clone_range!(target, chmin, chmax, offset)
    nvseed.save!

    serv_json({from: i_chmin})
  end

  def trunc
    sname = params["sname"]
    raise Unauthorized.new("Bạn không đủ quyền hạn") unless can_patch_seed?(sname)
  end

  def prune
    nvseed = self.nvseed
    nvseed.update({shield: _cvuser.privi > 2 ? 4 : 3})
    serv_json({shield: nvseed.shield})
  end
end
