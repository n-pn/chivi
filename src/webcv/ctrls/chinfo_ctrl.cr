class CV::ChinfoCtrl < CV::BaseCtrl
  def ch_info
    chroot = load_chroot
    chinfo = load_chinfo(chroot)

    cpart = params.read_i16("cpart", min: 0_i16)
    spawn Nvstat.inc_chap_view(chroot.nvinfo.id)

    ubmemo = Ubmemo.find_or_new(_viuser.id, chroot.nvinfo_id)
    ubmemo.mark_chap!(chinfo, chroot.sname, cpart) if _viuser.privi >= 0

    redo = _viuser.privi > 0 && params["redo"]? == "true"

    cvdata, rl_key = load_cvdata(chroot, chinfo, cpart, redo)

    serv_json do |jb|
      jb.object {
        jb.field "chmeta" { ChmetaView.new(chroot, chinfo, cpart).to_json(jb) }
        jb.field "chinfo" { ChinfoView.new(chinfo).to_json(jb) }
        jb.field "chmemo" { UbmemoView.new(ubmemo).to_json(jb) }

        jb.field "cvdata", cvdata
        jb.field "rl_key", rl_key
      }
    end
  end

  private def load_cvdata(chroot : Chroot, chinfo : Chinfo,
                          cpart : Int16 = 0_i16, redo : Bool = false)
    min_privi = chap_min_privi(chroot, chinfo)
    return {"", ""} if min_privi > _viuser.privi

    ukey = {chinfo.sname, chinfo.s_bid, chinfo.ch_no!, cpart}.join(":")
    utime = Time.unix(chinfo.utime) + 10.minutes

    if redo || !(qtran = QtranData::CACHE.get?(ukey, utime))
      mode = ChSeed.is_remote?(chinfo.sn_id) ? (redo ? 2_i8 : 1_i8) : 0_i8

      qtran = QtranData.load_chap(chroot, chinfo, cpart, mode: mode, uname: _viuser.uname)
      QtranData::CACHE.set(ukey, qtran)
    end

    return {"", ukey} if qtran.input.empty?

    cvdata = String.build do |io|
      engine = qtran.make_engine(_viuser.uname)
      trad = params["trad"]? == "true"
      qtran.print_mtl(engine, io, format: :node, title: true, trad: trad)
      qtran.print_raw(io)
    end

    {cvdata, ukey}
  rescue ex
    Log.error(exception: ex) { ex.message.colorize.red }
    {"", ""}
  end

  private def chap_min_privi(chroot : Chroot, chinfo : Chinfo)
    privi_map = chroot.privi_map
    free_chap = chroot.free_chap

    case
    when chinfo.ch_no! <= free_chap then privi_map[0]
    when chinfo.utime > 0           then privi_map[1]
    else                                 privi_map[2]
    end
  end
end
