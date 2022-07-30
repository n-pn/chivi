class CV::TlspecCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(min: 50)
    total = Tlspec.items.size

    send_json(
      {
        total: total,
        pgidx: pgidx,
        pgmax: CtrlUtil.pgmax(total, limit),
        items: Tlspec.items.skip(offset).first(limit).compact_map do |ukey|
          entry = Tlspec.load!(ukey)
          last_edit = entry.edits.last
          ztext = entry.ztext[last_edit.lower...last_edit.upper]
          cvmtl = MtCore.generic_mtl(entry.dname)

          {
            _ukey: ukey,
            ztext: ztext,
            d_dub: entry.d_dub,
            mtime: last_edit.mtime,
            uname: entry.edits.first.uname,
            privi: entry.edits.first.privi,
            match: last_edit.match,
            cvmtl: cvmtl.cv_plain(ztext, cap_first: false).to_txt,
          }
        rescue
          nil
        end,
      }
    )
  end

  def create
    return halt! 403, "Quyền hạn của bạn không đủ." if _viuser.privi < 0

    ztext = params.fetch_str("ztext")

    _ukey = UkeyUtil.gen_ukey(Time.utc)
    entry = Tlspec.new(_ukey, fresh: true)

    entry.ztext = ztext.strip
    entry.dname = params.fetch_str("dname", "combine")
    entry.d_dub = params.fetch_str("d_dub", "Tổng hợp")

    entry.add_edit!(params, _viuser)
    entry.save!

    serv_text(_ukey)
  end

  def show
    ukey = params["ukey"]
    entry = Tlspec.load!(ukey)

    last_edit = entry.edits.last
    lower = last_edit.lower
    upper = last_edit.upper

    ztext = entry.ztext[lower...upper]
    dname = entry.dname

    cvmtl = MtCore.generic_mtl(dname)

    send_json({
      ztext: entry.ztext,
      lower: lower,
      upper: upper,
      dname: dname,
      d_dub: entry.d_dub,
      uname: entry.edits.first.uname,
      privi: entry.edits.first.privi,
      entry: {
        _ukey: ukey,
        match: last_edit.match,
        extra: last_edit.extra,
        cvmtl: cvmtl.cv_plain(ztext, cap_first: false).to_txt,
      },
      # edits: entry.edits,
    })
  end

  def update
    entry = Tlspec.load!(params["ukey"])

    unless _viuser.privi > 2 || entry.edits.first.uname == _viuser.uname
      return halt! 403, "Bạn không đủ quyền hạn để sửa!"
    end

    entry.add_edit!(params, _viuser)
    entry.save!

    send_json(["ok"])
  end

  def delete
    entry = Tlspec.load!(params["ukey"])

    unless _viuser.privi > 2 || entry.edits.first.uname == _viuser.uname
      return halt! 403, "Bạn không đủ quyền hạn để xoá!"
    end

    entry.delete!

    send_json(["ok"])
  end
end
