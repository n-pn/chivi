class CV::ChrootCtrl < CV::BaseCtrl
  def index
    nslist = load_nvinfo.seed_list
    serv_json(NslistView.new(nslist))
  end

  def show
    chroot = load_chroot

    mode = params.read_i8("mode", min: 0_i8, max: max_mode_by_privi)
    reload_chroot(chroot, mode: mode)

    fresh = chroot.fresh?(_viuser.privi, force: false)
    serv_json(ChrootView.new(chroot, full: true, fresh: fresh))
  end

  private def max_mode_by_privi : Int8
    privi = _viuser.privi
    privi < 0 ? 0_i8 : privi > 1 ? 2_i8 : 1_i8
  end

  private def reload_chroot(chroot : Chroot, mode : Int8 = 0) : Nil
    case chroot._repo.stype
    when -2_i8 then chroot.reload_base!(mode: mode)
    when -1_i8 then chroot.reload_user!(mode: mode)
    when 0_i8 # @users
      return unless chroot.sname == "@" + _viuser.uname
      chroot.reload_self!(mode: mode) if mode > 0
    when 3_i8 # slow source
      chroot.reload_remote!(mode: mode) if mode > 0
    when 4_i8 # fast souce
      chroot.reload_remote!(mode: mode)
    else # miscs, zxcs_me, bxwxorg
      chroot.reload_frozen!(mode: mode)
    end

    chroot.stime = Time.utc.to_unix if mode > 0
    chroot.save! if chroot.changed?
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

    chroot.clear_cache!
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

    chroot.clear_cache!
    serv_json({shield: chroot.shield})
  end
end
