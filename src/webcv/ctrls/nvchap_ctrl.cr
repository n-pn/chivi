class CV::NvchapCtrl < CV::BaseCtrl
  private def load_nvseed
    nvinfo_id = params["book"].to_i64
    sname = params.fetch_str("sname", "union")
    Nvseed.load!(nvinfo_id, SnameMap.map_int(sname))
  end

  def ch_info
    chidx = params.fetch_int("chidx")
    cpart = params.fetch_int("cpart", min: 0)

    nvseed = load_nvseed
    unless chinfo = nvseed.chinfo(chidx - 1)
      raise NotFound.new("Chương tiết không tồn tại")
    end

    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvseed.nvinfo_id)
    ubmemo.mark_chap!(chinfo, nvseed.sname, cpart) if _cvuser.privi > -1

    chidx_max, min_privi = check_privi(nvseed, chinfo)

    redo = params["redo"]? == "true"
    trad = params["trad"]? == "true"

    serv_json do |jb|
      jb.object {
        jb.field "chmeta" { ChmetaView.new(nvseed, chinfo, cpart).to_json(jb) }
        jb.field "chinfo" { ChinfoView.new(chinfo).to_json(jb) }
        jb.field "ubmemo" { UbmemoView.new(ubmemo).to_json(jb) }

        jb.field "chidx_max", chidx_max
        jb.field "min_privi", min_privi

        if _cvuser.privi >= min_privi
          ukey = QtranData.text_ukey(nvseed.id, chinfo.chidx, cpart)
          QtranData::CACHE.delete(ukey) if redo

          qtran = QtranData.load!(ukey) do
            lines = load_text(nvseed, chinfo, cpart, redo)
            nvinfo = nvseed.nvinfo
            QtranData.new(lines, nvinfo.dname, nvinfo.vname, title: true)
          end

          cvdata = String.build do |io|
            qtran.print_mtl(io, _cvuser.uname, :node, trad: trad)
            qtran.print_raw(io)
          rescue ex
            Log.error(exception: ex) { "Error: #{ex.message}" }
          end

          jb.field "rl_key", ukey
          jb.field "cvdata", cvdata
        else
          jb.field "cvdata", ""
        end
      }
    end
  end

  private def load_text(nvseed : Nvseed, chinfo : ChInfo, cpart = 0, redo = false)
    sname = chinfo.proxy.try(&.sname) || nvseed.sname
    stype = SnameMap.map_type(sname)

    mode = stype < 3 ? 0 : (redo ? 2 : 1)

    lines = nvseed.chtext(chinfo, cpart, mode: mode, uname: _cvuser.uname)
    lines.tap do |x|
      parts = chinfo.stats.parts
      x[0] += "#{cpart + 1}/#{parts}" if parts > 1
    end
  end

  private def check_privi(nvseed : Nvseed, chinfo : ChInfo) : {Int32, Int32}
    # lower privi requirement if chapter < 1/3 total chap
    chidx_max = nvseed.chap_count // 3
    chidx_max = 40 if chidx_max < 40

    sname = chinfo.proxy.try(&.sname) || nvseed.sname
    stype = SnameMap.map_type(sname)

    min_privi = nvseed.zseed == 0 ? -1 : (stype < 3 || chinfo.stats.chars > 0 ? 0 : 1)
    min_privi &+= chinfo.chidx > chidx_max ? 1 : 0

    {chidx_max, min_privi}
  end

  def zh_text
    if _cvuser.privi < 2
      raise Unauthorized.new("Quyền hạn không đủ!")
    end

    nvseed = load_nvseed
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

  private def convert(nvseed, chinfo, lines : Array(String), cpart : Int32, strio : IO)
    return if lines.empty?

    cvmtl = MtCore.generic_mtl(nvseed.nvinfo.dname, _cvuser.uname)

    cvmtl.cv_title_full(lines[0]).to_str(strio)
    strio << "\t" << " [#{cpart + 1}/#{chinfo.stats.parts}]" if chinfo.stats.parts > 1

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      # File.write("tmp/nvchap.txt", "#{dname}\n#{line}")

      strio << "\n"
      cvmtl.cv_plain(line).to_str(strio)
    rescue err
      strio << "\t[[Máy dịch gặp lỗi, mời liên hệ ban quản trị]]"
      Log.error { err }
    end
  end

  def upsert
    if _cvuser.privi < 2 || params["sname"] != "users"
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

      chinfo.tap(&.set_title!(chap.title, chap.chvol))
    end

    stime = Time.utc.to_unix
    # save chapter infos
    nvseed.tap(&.patch!(infos, stime)).reset_cache!
    nvseed.nvinfo.tap(&.add_nvseed(nvseed.zseed)).save!

    # copy new uploaded chapters to "union" source
    infos.map!(&.as_proxy!("users", nvseed.snvid))

    mixed_seed = Nvseed.load!(nvseed.nvinfo, 0)
    mixed_seed.tap(&.patch!(infos, stime)).reset_cache!

    first = infos.first.tap(&.trans!(nvseed.cvmtl))
    send_json({chidx: chidx, uslug: first.trans.uslug}, 201)
  end
end
