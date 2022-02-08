require "./_base_ctrl"

class CV::TlspecCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(min: 50)

    total = Tlspec.items.size

    send_json(
      {
        total: total,
        pgidx: pgidx,
        pgmax: CtrlUtil.pgmax(total, limit),
        items: Tlspec.items[offset..(offset + limit)].map do |ukey|
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
            cvmtl: cvmtl.cv_plain(ztext, cap_first: false).to_s,
          }
        end,
      }
    )
  end

  def create
    return halt! 403, "Quyền hạn của bạn không đủ." if _cvuser.privi < 0

    ztext = params.fetch_str("ztext")

    _ukey = UkeyUtil.gen_ukey(Time.utc)
    entry = Tlspec.new(_ukey, fresh: true)

    entry.ztext = ztext.strip
    entry.dname = params.fetch_str("dname", "combine")
    entry.d_dub = params.fetch_str("d_dub", "Tổng hợp")

    entry.add_edit!(params, _cvuser)
    entry.save!

    send_json(["ok"])
  rescue err
    Log.error { err.message.colorize.red }
    halt! 500, "Có lỗi từ hệ thống, mời check lại!"
  end

  def show
    ukey = params["ukey"]
    entry = Tlspec.load!(ukey)

    last_edit = entry.edits.last
    lower = last_edit.lower
    upper = last_edit.upper

    ztext = entry.ztext[lower...upper]
    cvmtl = MtCore.generic_mtl(entry.dname)

    send_json({
      ztext: entry.ztext,
      lower: lower,
      upper: upper,
      dname: entry.dname,
      d_dub: entry.d_dub,
      uname: entry.edits.first.uname,
      privi: entry.edits.first.privi,
      entry: {
        _ukey: ukey,
        match: last_edit.match,
        extra: last_edit.extra,
        cvmtl: cvmtl.cv_plain(ztext, cap_first: false).to_s,
      },
      # edits: entry.edits,
    })
  rescue err
    puts err

    halt! 500, err.message
  end

  def update
    entry = Tlspec.load!(params["ukey"])

    unless _cvuser.privi > 2 || entry.edits.first.uname == _cvuser.uname
      return halt! 403, "Bạn không đủ quyền hạn để sửa!"
    end

    entry.add_edit!(params, _cvuser)
    entry.save!

    send_json(["ok"])
  end

  def delete
    entry = Tlspec.load!(params["ukey"])

    unless _cvuser.privi > 2 || entry.edits.first.uname == _cvuser.uname
      return halt! 403, "Bạn không đủ quyền hạn để xoá!"
    end

    entry.delete!

    send_json(["ok"])
  end
end
