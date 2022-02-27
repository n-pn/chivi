require "./_base_ctrl"

class CV::NvchapCtrl < CV::BaseCtrl
  private def load_zhbook
    nvinfo_id = params["book"].to_i64
    sname = params.fetch_str("sname", "chivi")
    Zhbook.load!(nvinfo_id, SeedUtil.map_id(sname))
  end

  def ch_seed
    nvinfo = Nvinfo.load!(params["book"].to_i64)

    sname = params.fetch_str("sname", "chivi")
    zhbook = Zhbook.load!(nvinfo.id, SeedUtil.map_id(sname))

    force = params["force"]? == "true" && _cvuser.privi >= 0
    zhbook.refresh!(force: force) if zhbook.staled?(_cvuser.privi, force)

    send_json({chseed: nvinfo.zhbooks.to_a.map { |x| ChseedView.new(x) }})
  end

  def ch_list
    zhbook = load_zhbook

    force = params["force"]? == "true" && _cvuser.privi >= 0
    zhbook.refresh!(force: force) if zhbook.staled?(_cvuser.privi, force)

    total = zhbook.chap_count
    pgidx = params.fetch_int("pg", min: 1)

    send_json({
      nvseed: zhbook.nvinfo.zhbooks.to_a.map { |x| ChseedView.new(x) },
      chseed: ChseedView.new(zhbook),
      chpage: {
        sname: zhbook.sname,
        total: total,
        pgidx: pgidx,
        pgmax: CtrlUtil.pgmax(total, 32),
        lasts: zhbook.lastpg.to_a,
        chaps: zhbook.chpage(pgidx - 1).to_a,
      },
    })
  end

  private def seed_outdated?(zhbook : Zhbook, privi = 0)
    tspan = Time.utc - Time.unix(zhbook.atime)
    bonus = 4 - privi

    case zhbook.status
    when 0 then tspan > 2.hours * bonus
    when 1 then tspan > 2.days * bonus
    when 2 then tspan > 2.weeks * bonus
    else        false
    end
  end

  def ch_info
    chidx = params.fetch_int("chidx")
    cpart = params.fetch_int("cpart", min: 0)

    zhbook = load_zhbook
    return text_not_found! unless chinfo = zhbook.chinfo(chidx - 1)

    mode = !remote_chap?(zhbook, chinfo) ? 0 : params["redo"]? ? 2 : 1
    lines = zhbook.chtext(chinfo, cpart, mode: mode, uname: _cvuser.uname)

    ubmemo = Ubmemo.find_or_new(_cvuser.id, zhbook.nvinfo_id)
    if _cvuser.privi > -1
      trans = chinfo.trans
      ubmemo.mark!(zhbook.sname, chidx, cpart, trans.title, trans.uslug)
    end

    send_json do |jb|
      jb.object {
        jb.field "chmeta" {
          jb.object {
            jb.field "sname", zhbook.sname
            jb.field "total", zhbook.chap_count

            jb.field "cpart", cpart
            jb.field "clink", zhbook.clink(chinfo.schid)

            jb.field "_prev", cpart == 0 ? zhbook.chap_url(chidx - 1, -1) : chinfo.chap_url(cpart - 1)
            jb.field "_next", cpart + 1 < chinfo.stats.parts ? chinfo.chap_url(cpart + 1) : zhbook.chap_url(chidx + 1)
          }
        }

        jb.field "chinfo" { chinfo.to_json(jb) }
        jb.field "ubmemo" { UbmemoView.render(jb, ubmemo) }

        jb.field "zhtext", lines

        # start = Time.monotonic

        strio = String::Builder.new
        convert(zhbook, chinfo, lines, cpart, strio)
        jb.field "cvdata" { jb.string(strio.to_s) }

        # tspan = (Time.monotonic - start).total_milliseconds.round.to_i
        # jb.field "tlspan", tspan
      }
    end
  end

  private def remote_chap?(chseed : Zhbook, chinfo : ChInfo)
    sname = chinfo.proxy.try(&.sname) || chseed.sname

    SeedUtil.remote?(sname, _cvuser.privi) do
      chidx = chinfo.chidx
      count = chseed.chap_count
      chidx >= count - 8 || chidx <= 40 || chidx <= count // 3
    end
  end

  def zh_text
    return halt!(500, "Quyền hạn không đủ!") if _cvuser.privi < 2

    zhbook = load_zhbook
    chidx = params.fetch_int("chidx")

    return text_not_found! unless chinfo = zhbook.chinfo(chidx - 1)

    set_cache :private, maxage: 5 - _cvuser.privi
    set_headers content_type: :text

    response << "//// #{chinfo.chvol}\n#{chinfo.title}\n"

    chinfo.stats.parts.times do |cpart|
      lines = zhbook.chtext(chinfo, cpart)
      1.upto(lines.size - 1) { |i| response << '\n' << lines.unsafe_fetch(i) }
    end
  end

  def cv_text : Nil
    chidx = params.fetch_int("chidx") { 1 }
    cpart = params.fetch_int("cpart") { 0 }

    zhbook = load_zhbook
    return text_not_found! unless chinfo = zhbook.chinfo(chidx - 1)

    set_cache :private, maxage: 5 - _cvuser.privi
    set_headers content_type: :text

    lines = zhbook.chtext(chinfo, cpart, mode: 0, uname: _cvuser.uname)
    convert(zhbook, chinfo, lines, cpart, response)
  end

  private def text_not_found!(status = 404)
    halt! 404, "Chương tiết không tồn tại!"
  end

  private def convert(zhbook, chinfo, lines : Array(String), cpart : Int32, strio : IO)
    return if lines.empty?

    cvmtl = MtCore.generic_mtl(zhbook.nvinfo.dname, _cvuser.uname)

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

    zhbook = load_zhbook
    chidx = params.fetch_int("chidx") { 1 }

    input = params.fetch_str("input")
    lines = TextUtil.split_text(input, false)

    if params["_trad"]? == "true"
      lines.map! { |x| MtCore.trad_to_simp(x) }
    end

    chaps = split_chaps(lines, "")
    chidx = zhbook.chap_count + 1 if chidx < 1

    infos = chaps.map_with_index(chidx) do |chap, c_idx|
      if chinfo = zhbook.chinfo(c_idx - 1)
        chinfo.bump_version!
      else
        chinfo = ChInfo.new(c_idx, (c_idx * 10).to_s)
      end

      chinfo.stats.uname = _cvuser.uname
      ChText.new(zhbook.sname, zhbook.snvid, chinfo).save!(chap.lines)

      chinfo.tap(&.set_title!(chap.title, chap.chvol))
    end

    # save chapter infos
    zhbook.patch!(infos)
    zhbook.reset_cache!

    # copy new uploaded chapters to "chivi" source
    infos.map!(&.as_proxy!("users", zhbook.snvid))
    Zhbook.load!(zhbook.nvinfo, 0).patch!(infos)

    first = infos.first.tap(&.trans!(zhbook.cvmtl))
    send_json({chidx: chidx, uslug: first.trans.uslug}, 201)
  end

  struct Chap
    getter chvol : String
    getter lines = [] of String
    getter title : String { lines.first? || "" }

    def initialize(@chvol)
    end
  end

  LINE_RE = /^\/{3,}(.*)$/

  private def split_chaps(input : Array(String), chvol = "")
    chaps = [Chap.new(chvol)]

    input.each do |line|
      if match = LINE_RE.match(line)
        extra = match[1].strip
        chvol = extra unless extra.empty? || extra == "正文"
        chaps << Chap.new(chvol)
      else
        line = line.strip
        chaps.last.lines << line unless line.empty?
      end
    end

    chaps.shift if chaps.first.lines.empty?
    chaps
  end
end
