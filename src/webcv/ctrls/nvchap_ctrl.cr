class CV::NvchapCtrl < CV::BaseCtrl
  def ch_info
    chidx = params.fetch_int("chidx")
    cpart = params.fetch_int("cpart", min: 0)

    nvseed = load_nvseed
    nvinfo = nvseed.nvinfo

    unless chinfo = nvseed.chinfo(chidx - 1)
      raise NotFound.new("Chương tiết không tồn tại")
    end

    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvseed.nvinfo_id)
    ubmemo.mark_chap!(chinfo, nvseed.sname, cpart) if _cvuser.privi > -1

    sname, stype, chidx_max, min_privi = check_privi(nvseed, chinfo)

    redo = params["redo"]? == "true"
    trad = params["trad"]? == "true"

    QtranData.clear_chaps_cache(nvseed.id, chinfo.chidx, chinfo.stats.parts) if redo

    serv_json do |jb|
      jb.object {
        jb.field "chidx_max", chidx_max
        jb.field "min_privi", min_privi

        if _cvuser.privi >= min_privi
          if nvseed.sname == "union" # load proxy instead
            nvseed_id = Nvseed.load!(nvinfo, sname).id
          else
            nvseed_id = nvseed.id
          end

          ukey = QtranData.nvchap_ukey(nvseed_id, chinfo.chidx, cpart)

          qtran = QtranData.load_cached(ukey, "chaps") do
            mode = stype < 3 ? 0 : (redo ? 2 : 1)
            lines = nvseed.chtext(chinfo, cpart, mode: mode, uname: _cvuser.uname)

            QtranData.nvchap(lines, nvinfo, chinfo.stats, cpart)
          end

          cvdata = String.build do |io|
            engine = qtran.make_engine(_cvuser.uname)
            qtran.print_mtl(engine, io, format: :node, title: true, trad: trad)
          rescue ex
            Log.error(exception: ex) { "Error: #{ex.message}" }
          end

          jb.field "rl_key", ukey
          jb.field "cvdata", cvdata
          jb.field "zhtext", qtran.input
        else
          jb.field "cvdata", ""
          jb.field "zhtext", [] of String
        end

        jb.field "chmeta" { ChmetaView.new(nvseed, chinfo, cpart).to_json(jb) }
        jb.field "chinfo" { ChinfoView.new(chinfo).to_json(jb) }
        jb.field "ubmemo" { UbmemoView.new(ubmemo).to_json(jb) }
      }
    end
  end

  private def check_privi(nvseed : Nvseed, chinfo : ChInfo) : {String, Int32, Int32, Int32}
    # lower privi requirement if chapter < 1/3 total chap
    chidx_max = nvseed.chap_count // 3
    chidx_max = 40 if chidx_max < 40

    sname = chinfo.proxy.try(&.sname) || nvseed.sname
    stype = SnameMap.map_type(sname)

    min_privi = nvseed.sname == "union" ? -1 : (stype < 3 || chinfo.stats.chars > 0 ? 0 : 1)
    min_privi &+= chinfo.chidx > chidx_max ? 1 : 0

    {sname, stype, chidx_max, min_privi}
  end

  def zh_text
    if _cvuser.privi < 2
      raise Unauthorized.new("Quyền hạn không đủ!")
    end

    nvseed = Nvseed.load!(params["book"].to_i64, params["sname"])
    chidx = params.fetch_int("chidx")

    unless chinfo = nvseed.chinfo(chidx - 1)
      raise NotFound.new("Chương tiết không tồn tại")
    end

    set_headers content_type: :text

    response << "/// #{chinfo.chvol}\n#{chinfo.title}\n"

    chinfo.stats.parts.times do |cpart|
      lines = nvseed.chtext(chinfo, cpart)
      1.upto(lines.size - 1) { |i| response << '\n' << lines.unsafe_fetch(i) }
    end
  end

  private def text_not_found!(status = 404)
    halt! 404, "Chương tiết không tồn tại!"
  end

  def upsert
    if _cvuser.privi < 2 || params["sname"] != "$self"
      return halt!(500, "Quyền hạn không đủ!")
    end

    nvseed = load_nvseed
    chidx = params.fetch_int("chidx") { 1 }

    input = params.fetch_str("input")
    lines = TextUtil.split_text(input, false)

    if params["_trad"]? == "true"
      lines.map! { |x| MtCore.trad_to_simp(x) }
    end

    chaps = ChUtil.split_chaps(lines, nvseed.get_chvol(chidx))
    chidx = nvseed.chap_count + 1 if chidx < 1

    infos = chaps.map_with_index(chidx) do |chap, c_idx|
      unless chinfo = nvseed.chinfo(c_idx - 1)
        chinfo = ChInfo.new(c_idx, (c_idx * 10).to_s)
      end

      chinfo.stats.uname = _cvuser.uname
      ChText.new(nvseed.sname, nvseed.snvid, chinfo).save!(chap.lines)
      QtranData.clear_chaps_cache(nvseed.id, chinfo.chidx, chinfo.stats.parts)

      chinfo.tap(&.set_title!(chap.title, chap.chvol))
    end

    stime = Time.utc.to_unix
    # save chapter infos
    nvseed.tap(&.patch!(infos, stime)).reset_cache!
    nvseed.nvinfo.tap(&.add_nvseed(nvseed.zseed)).save!

    # copy new uploaded chapters to "union" source
    infos.map!(&.as_proxy!("users", nvseed.snvid))

    mixed_seed = Nvseed.load!(nvseed.nvinfo, "union")
    mixed_seed.tap(&.patch!(infos, stime)).reset_cache!

    first = infos.first.tap(&.trans!(nvseed.cvmtl))
    send_json({chidx: chidx, uslug: first.trans.uslug}, 201)
  end
end
