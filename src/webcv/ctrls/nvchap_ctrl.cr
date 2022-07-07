class CV::NvchapCtrl < CV::BaseCtrl
  def ch_info
    nvseed = load_nvseed
    nvinfo = nvseed.nvinfo

    chidx = params.fetch_int("chidx")
    cpart = params.fetch_int("cpart", min: 0)

    unless chinfo = nvseed.chinfo(chidx - 1)
      raise NotFound.new("Chương tiết không tồn tại")
    end

    spawn Nvstat.inc_chap_view(nvinfo.id)

    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvseed.nvinfo_id)
    ubmemo.mark_chap!(chinfo, nvseed.sname, cpart) if _cvuser.privi > -1

    redo = params["redo"]? == "true"
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

  private def load_cvdata(nvseed : Nvseed, chinfo : ChInfo, cpart = 0, redo = false)
    min_privi = nvseed.min_privi(chinfo.chidx, chinfo.stats.chars)
    return {"", ""} if min_privi > _cvuser.privi

    if proxy = chinfo.proxy
      nvseed_id = Nvseed.load!(nvseed.nvinfo, proxy.sname).id
    else
      nvseed_id = nvseed.id
    end

    ukey = QtranData.nvchap_ukey(nvseed_id, chinfo.chidx, cpart)

    if redo
      chinfo.stats.parts.times do |idx|
        QtranData.clear_cache("chaps", ukey.sub(cpart.to_s, idx.to_s), disk: true)
      end
    end

    qtran = QtranData.load_cached(ukey, "chaps") do
      fetch_mode = nvseed.seed_type < 3 ? 0 : (redo ? 2 : 1)
      lines = nvseed.chtext(chinfo, cpart, mode: fetch_mode, uname: _cvuser.uname)
      QtranData.nvchap(lines, nvseed.nvinfo, chinfo.stats, cpart)
    end

    cvdata = String.build do |io|
      engine = qtran.make_engine(_cvuser.uname)
      trad = params["trad"]? == "true"
      qtran.print_mtl(engine, io, format: :node, title: true, trad: trad)
      qtran.print_raw(io)
    end

    {cvdata, ukey}
  rescue ex
    Log.error(exception: ex) { "Error: #{ex.message}" }
    {"", ""}
  end
end
