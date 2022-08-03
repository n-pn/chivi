class CV::NvchapCtrl < CV::BaseCtrl
  def ch_info
    chroot = load_chroot
    chinfo = load_chinfo(chroot)

    cpart = params.read_i16("cpart", min: 0_i16)

    # spawn Nvstat.inc_chap_view(chroot.nvinfo.id)

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
    min_privi = chroot.min_privi(chinfo.chidx, chinfo.w_count)
    return {"", ""} if min_privi > _viuser.privi

    if mirror = chinfo.mirror.try(&.chroot)
      ukey = {mirror.sname, mirror.snvid, chinfo.chidx, cpart}.join(":")
    else
      ukey = {chroot.sname, chroot.snvid, chinfo.chidx, cpart}.join(":")
    end

    utime = (chinfo.changed_at || Time.utc) + 10.minutes
    if redo || !(qtran = QtranData::CACHE.get?(ukey, utime))
      qtran = QtranData.load_chap(chinfo, cpart, redo: redo, viuser: _viuser)
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

  private def log_convert_error(chroot, chinfo, cpart, error)
    File.open("tmp/load_chap_error.log", "a") do |io|
      data = {
        time: Time.local,
        book: "#{chroot.nvinfo.bslug}  #{chroot.sname}  #{chroot.snvid}",
        chap: "#{chinfo.chidx}  #{chinfo.schid}  #{cpart}",
        _err: error,
      }

      io.puts(data.to_json)
    end
  end
end
