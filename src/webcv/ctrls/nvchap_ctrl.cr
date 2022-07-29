class CV::NvchapCtrl < CV::BaseCtrl
  def ch_info
    nvseed = load_nvseed
    nvinfo = nvseed.nvinfo

    chidx = params.read_i16("chidx", min: 1_i16)
    cpart = params.read_i16("cpart")

    unless chinfo = nvseed.chinfo(chidx - 1)
      raise NotFound.new("Chương tiết không tồn tại")
    end

    spawn Nvstat.inc_chap_view(nvinfo.id)

    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvseed.nvinfo_id)
    ubmemo.mark_chap!(chinfo, nvseed.sname, cpart) if _cvuser.privi > -1

    redo = _cvuser.privi > 0 && params["redo"]? == "true"
    cvdata, rl_key = load_cvdata(nvseed, chinfo, cpart, redo)

    serv_json do |jb|
      jb.object {
        jb.field "chmeta" { ChmetaView.new(nvseed, chinfo, cpart).to_json(jb) }
        jb.field "chinfo" { ChinfoView.new(chinfo).to_json(jb) }
        jb.field "chmemo" { UbmemoView.new(ubmemo).to_json(jb) }

        jb.field "cvdata", cvdata
        jb.field "rl_key", rl_key
      }
    end
  end

  private def load_cvdata(nvseed : Nvseed, chinfo : ChInfo, cpart = 0_i16, redo = false)
    stats = chinfo.stats

    min_privi = nvseed.min_privi(chinfo.chidx, stats.chars)
    return {"", ""} if min_privi > _cvuser.privi

    if proxy = chinfo.proxy
      ukey = {proxy.sname, proxy.snvid, chinfo.chidx, cpart}.join(":")
    else
      ukey = {nvseed.sname, nvseed.snvid, chinfo.chidx, cpart}.join(":")
    end

    if redo || !(qtran = QtranData::CACHE.get?(ukey, Time.unix(stats.utime) + 10.minutes))
      qtran = QtranData.load_chap(nvseed, chinfo, cpart, redo: redo, uname: _cvuser.uname)
      QtranData::CACHE.set(ukey, qtran)
    end

    if qtran.input.empty?
      spawn log_convert_error(nvseed, chinfo, cpart, "No text loaded")
      return {"", ukey}
    end

    cvdata = String.build do |io|
      engine = qtran.make_engine(_cvuser.uname)
      trad = params["trad"]? == "true"
      qtran.print_mtl(engine, io, format: :node, title: true, trad: trad)
      qtran.print_raw(io)
    end

    {cvdata, ukey}
  rescue ex
    spawn log_convert_error(nvseed, chinfo, cpart, ex.message)
    {"", ""}
  end

  private def log_convert_error(nvseed, chinfo, cpart, error)
    File.open("tmp/load_chap_error.log", "a") do |io|
      data = {
        time: Time.local,
        book: "#{nvseed.nvinfo.bslug}  #{nvseed.sname}  #{nvseed.snvid}",
        chap: "#{chinfo.chidx}  #{chinfo.schid}  #{cpart}",
        _err: error,
      }

      io.puts(data.to_json)
    end
  end
end
