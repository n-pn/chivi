require "./_base_ctrl"

class CV::NvchapCtrl < CV::BaseCtrl
  private def load_nvseed
    nvinfo_id = params["book"].to_i64
    sname = params.fetch_str("sname", "chivi")
    Nvseed.load!(nvinfo_id, SnameMap.map_int(sname))
  end

  def ch_seed
    nvinfo = Nvinfo.load!(params["book"].to_i64)

    sname = params.fetch_str("sname", "chivi")
    nvseed = Nvseed.load!(nvinfo.id, SnameMap.map_int(sname))

    force = params["force"]? == "true" && _cvuser.privi >= 0
    nvseed.refresh!(force: force) if nvseed.staled?(_cvuser.privi, force)

    send_json({chseed: nvinfo.nvseeds.to_a.map { |x| ChseedView.new(x) }})
  end

  def ch_list
    nvseed = load_nvseed
    bseeds = nvseed.nvinfo.nvseeds

    force = params["force"]? == "true" && _cvuser.privi >= 0
    nvseed.refresh!(force: force) if nvseed.staled?(_cvuser.privi, force)

    total = nvseed.chap_count
    pgidx = params.fetch_int("pg", min: 1)

    send_json({
      nvseed: bseeds.to_a.sort_by!(&.zseed).map { |x| ChseedView.new(x) },
      chseed: ChseedView.new(nvseed),
      chpage: {
        sname: nvseed.sname,
        total: total,
        pgidx: pgidx,
        pgmax: CtrlUtil.pgmax(total, 32),
        lasts: nvseed.lastpg.to_a.map { |x| ChinfoView.new(x) },
        chaps: nvseed.chpage(pgidx - 1).map { |x| ChinfoView.new(x) },
      },
    })
  end

  private def seed_outdated?(nvseed : Nvseed, privi = 0)
    tspan = Time.utc - Time.unix(nvseed.atime)
    bonus = 4 - privi

    case nvseed.status
    when 0 then tspan > 2.hours * bonus
    when 1 then tspan > 2.days * bonus
    when 2 then tspan > 2.weeks * bonus
    else        false
    end
  end

  def ch_info
    chidx = params.fetch_int("chidx")
    cpart = params.fetch_int("cpart", min: 0)

    nvseed = load_nvseed
    return text_not_found! unless chinfo = nvseed.chinfo(chidx - 1)

    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvseed.nvinfo_id)
    ubmemo.mark_chap!(chinfo, nvseed.sname, cpart) if _cvuser.privi > -1

    lines, min_privi, chidx_max = load_text(nvseed, chinfo, cpart, params["redo"]? == "true")

    send_json do |jb|
      jb.object {
        jb.field "chmeta" { ChmetaView.new(nvseed, chinfo, cpart).to_json(jb) }
        jb.field "chinfo" { ChinfoView.new(chinfo).to_json(jb) }
        jb.field "ubmemo" { UbmemoView.new(ubmemo).to_json(jb) }

        jb.field "min_privi", min_privi
        jb.field "chidx_max", chidx_max

        jb.field "zhtext", lines

        # start = Time.monotonic

        strio = String::Builder.new
        convert(nvseed, chinfo, lines, cpart, strio)
        jb.field "cvdata" { jb.string(strio.to_s) }

        # tspan = (Time.monotonic - start).total_milliseconds.round.to_i
        # jb.field "tlspan", tspan
      }
    end
  end

  private def load_text(nvseed : Nvseed, chinfo : ChInfo, cpart = 0, redo = false)
    sname = chinfo.proxy.try(&.sname) || nvseed.sname
    stype = SnameMap.map_type(sname)

    # lower privi requirement if chapter < 1/3 total chap
    chidx_max = nvseed.chap_count // 3
    chidx_max = 40 if chidx_max < 40

    min_privi = nvseed.zseed == 0 ? -1 : (stype < 3 || chinfo.stats.chars > 0 ? 0 : 1)
    min_privi &+= chinfo.chidx > chidx_max ? 1 : 0

    mode = stype < 3 ? 0 : (redo ? 2 : 1)
    lines = _cvuser.privi < min_privi ? [] of String : nvseed.chtext(chinfo, cpart, mode: mode)

    {lines, min_privi, chidx_max}
  end

  def zh_text
    return halt!(500, "Quyền hạn không đủ!") if _cvuser.privi < 2

    nvseed = load_nvseed
    chidx = params.fetch_int("chidx")

    return text_not_found! unless chinfo = nvseed.chinfo(chidx - 1)

    set_cache :private, maxage: 5 - _cvuser.privi
    set_headers content_type: :text

    response << "/// #{chinfo.chvol}\n#{chinfo.title}\n"

    chinfo.stats.parts.times do |cpart|
      lines = nvseed.chtext(chinfo, cpart)
      1.upto(lines.size - 1) { |i| response << '\n' << lines.unsafe_fetch(i) }
    end
  end

  def cv_text : Nil
    chidx = params.fetch_int("chidx") { 1 }
    cpart = params.fetch_int("cpart") { 0 }

    nvseed = load_nvseed
    return text_not_found! unless chinfo = nvseed.chinfo(chidx - 1)

    set_cache :private, maxage: 5 - _cvuser.privi
    set_headers content_type: :text

    lines = load_text(nvseed, chinfo, cpart).first
    convert(nvseed, chinfo, lines, cpart, response)
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

    # save chapter infos
    nvseed.tap(&.patch!(infos)).reset_cache!
    nvseed.nvinfo.tap(&.add_nvseed(nvseed.zseed)).save!

    # copy new uploaded chapters to "chivi" source
    infos.map!(&.as_proxy!("users", nvseed.snvid))
    Nvseed.load!(nvseed.nvinfo, 0).tap(&.patch!(infos)).reset_cache!

    first = infos.first.tap(&.trans!(nvseed.cvmtl))
    send_json({chidx: chidx, uslug: first.trans.uslug}, 201)
  end
end
