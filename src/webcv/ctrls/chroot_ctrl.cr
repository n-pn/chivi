class CV::ChrootCtrl < CV::BaseCtrl
  def index
    nslist = load_nvinfo.seed_list
    serv_json(NslistView.new(nslist))
  end

  def show
    nvseed = load_chroot
    mode = params.read_i8("mode", 0_i8)

    if mode > 0 && can_reload?(nvseed)
      nvseed.reload!(mode: mode)
      fresh = true
    else
      fresh = nvseed.fresh?(_viuser.privi, force: false)
    end

    serv_json(ChrootView.new(nvseed, full: true, fresh: fresh))
  end

  private def can_reload?(nvseed : Chroot)
    return false if _viuser.privi < 0
    return true unless nvseed.sname[0] == '@'
    nvseed.sname == '@' + _viuser.uname
  end

  def chaps
    nvseed = load_chroot
    pgidx = params.read_i16("page", min: 1_i16)
    chaps = nvseed.chpage(pgidx &- 1)

    serv_json({
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(nvseed.chap_count, 32_i16),
      chaps: ChinfoView.list(chaps),
    })
  end

  def create
    assert_privi 2

    nvinfo = load_nvinfo

    sname = params["sname"]
    snvid = params["snvid"]

    nvseed = Chroot.upsert!(nvinfo, sname, snvid, force: true)
    nvinfo.seed_list.other.push(nvseed).sort! { |x| SnameMap.zseed(x.sname) }

    serv_json({sname: sname, snvid: snvid})
  end

  before_action do
    only [:patch, :trunc, :prune] do
    end
  end

  private def load_guarded_nvseed(min_privi = 1) : Chroot
    sname = params["sname"]
    return load_chroot(sname) if action_allowed?(sname, min_privi)
    raise Unauthorized.new("Bạn không đủ quyền hạn")
  end

  # modes: 0 => patch, 1 => trunc, 2 => prune

  private def action_allowed?(sname : String, min_privi = 1)
    privi = _viuser.privi
    return true if privi > 3

    case sname[0]?
    when '=' then privi >= min_privi
    when '@' then privi >= min_privi && sname == '@' + _viuser.uname
    else          privi > min_privi
    end
  end

  def patch
    nvseed = load_guarded_nvseed(min_privi: 1)
    target = Chroot.load!(nvseed.nvinfo, params["o_sname"])

    chmin = params.read_i16("chmin", min: 1_i16)
    chmax = params.read_i16("chmax", min: chmin, max: target.chap_count)

    new_chmin = params.read_i16("i_chmin", min: 1_i16)
    nvseed.mirror_other(target, chmin, chmax, new_chmin)

    serv_json({pgidx: (new_chmin &- 1) // 128 &+ 1})
  end

  def trunc
    nvseed = load_guarded_nvseed(min_privi: 2)
    trunc_chidx = params.read_i16("chidx", min: 1_i16, max: nvseed.chap_count)

    if chinfo = nvseed.chinfo(trunc_chidx &- 1)
      last_sname = chinfo.mirror.try(&.chroot.sname) || ""
      last_schid = chinfo.schid
    else
      last_sname = last_schid = ""
    end

    nvseed.update({
      chap_count: trunc_chidx &- 1,
      last_sname: last_sname,
      last_schid: last_schid,
    })

    serv_json({pgidx: (trunc_chidx - 1) // 128 + 1})
  end

  def prune
    nvseed = load_guarded_nvseed(min_privi: 2)

    nvseed.update({
      chap_count: 0_i16,
      last_sname: "",
      last_schid: "",
      shield:     _viuser.privi > 2 ? 4 : 3,
    })

    serv_json({shield: nvseed.shield})
  end
end
