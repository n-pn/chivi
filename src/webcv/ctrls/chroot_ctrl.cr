class CV::ChrootCtrl < CV::BaseCtrl
  def index
    nslist = load_nvinfo.seed_list
    serv_json(NslistView.new(nslist))
  end

  def show
    chroot = load_chroot
    mode = params.read_i8("mode", 0_i8)

    if mode > 0 && can_reload?(chroot)
      chroot.reload!(mode: mode)
      fresh = true
    else
      fresh = chroot.fresh?(_viuser.privi, force: false)
    end

    serv_json(ChrootView.new(chroot, full: true, fresh: fresh))
  end

  private def can_reload?(chroot : Chroot)
    return false if _viuser.privi < 0
    return true unless chroot.sname[0] == '@'
    chroot.sname == '@' + _viuser.uname
  end

  def chaps
    chroot = load_chroot
    pgidx = params.read_i16("page", min: 1_i16)
    chaps = chroot.chpage(pgidx &- 1)

    serv_json({
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(chroot.chap_count, 32_i16),
      chaps: ChinfoView.list(chaps),
    })
  end

  def create
    assert_privi 2

    nvinfo = load_nvinfo

    sname = params["sname"]
    s_bid = params["snvid"].to_i

    chroot = Chroot.upsert!(nvinfo, sname, s_bid, force: true)
    nvinfo.seed_list.other.push(chroot).sort! { |x| SnameMap.zseed(x.sname) }

    serv_json({sname: sname, snvid: s_bid})
  end

  before_action do
    only [:patch, :trunc, :prune] do
    end
  end

  private def load_guarded_chroot(min_privi = 1) : Chroot
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
    chroot = load_guarded_chroot(min_privi: 1)
    target = Chroot.load!(chroot.nvinfo, params["o_sname"])

    chmin = params.read_int("chmin", min: 1)
    chmax = params.read_int("chmax", min: chmin, max: target.chap_count)

    new_chmin = params.read_int("i_chmin", min: 1)
    chroot.mirror_other!(target, chmin, chmax, new_chmin)
    chroot.clear_cache!

    serv_json({pgidx: (new_chmin &- 1) // 128 &+ 1})
  end

  def trunc
    sname = params["sname"]
    guard_privi min: ACL.upsert_chtext(sname, _viuser.uname)

    chroot = load_chroot(sname, mode: :find)
    trunc_from = params.read_int("chidx", min: 1, max: chroot.chap_count)

    if chinfo = chroot.chinfo(trunc_from &- 1)
      last_sname = chinfo.sname
      last_schid = chinfo.s_cid.to_s
    else
      last_sname = ""
      last_schid = ""
    end

    chroot.update({
      chap_count: trunc_from &- 1,
      last_sname: last_sname,
      last_schid: last_schid,
    })

    serv_json({pgidx: (trunc_from - 1) // 128 + 1})
  end

  def prune
    sname = params["sname"]
    guard_privi min: ACL.upsert_chtext(sname, _viuser.uname)

    chroot = load_chroot(sname, mode: :find)

    chroot.update({
      chap_count: 0_i16,
      last_sname: "", last_schid: "",
      shield: _viuser.privi > 2 ? 4 : 3,
    })

    serv_json({shield: chroot.shield})
  end
end
