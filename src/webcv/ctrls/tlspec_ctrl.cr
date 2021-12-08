require "./base_ctrl"

class CV::TlspecCtrl < CV::BaseCtrl
  def index
    pgidx = params.fetch_int("page", min: 1)
    limit = 50
    start = (pgidx - 1) * limit
    total = Tlspec.items.size

    json_view do |jb|
      jb.object {
        jb.field "total", total
        jb.field "pgidx", pgidx
        jb.field "pgmax", (total - 1) // limit + 1

        jb.field "items" {
          jb.array {
            Tlspec.items[start..(start + limit)].each do |ukey|
              entry = Tlspec.load!(ukey)
              last_edit = entry.edits.last
              lower = last_edit.lower
              upper = last_edit.upper
              ztext = entry.ztext[lower...upper]
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
              }.to_json(jb)
            end
          }
        }
      }
    end
  end

  def create
    return halt! 403, "Quyền hạn của bạn không đủ." if u_privi < 0

    ztext = params.fetch_str("ztext")

    _ukey = UkeyUtil.gen_ukey(Time.utc)
    entry = Tlspec.new(_ukey, fresh: true)

    entry.ztext = ztext
    entry.dname = params.fetch_str("dname", "combine")
    entry.d_dub = params.fetch_str("d_dub", "Tổng hợp")

    entry.add_edit!(params, _cvuser)
    entry.save!

    json_view(["ok"])
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

    json_view({
      input: {
        ztext: entry.ztext,
        lower: lower,
        upper: upper,
      },
      entry: {
        _ukey: ukey,
        dname: entry.dname,
        d_dub: entry.d_dub,
        match: last_edit.match,
        extra: last_edit.extra,
        cvmtl: cvmtl.cv_plain(ztext, cap_first: false).to_s,
      },
      uname: entry.edits.first.uname,
      privi: entry.edits.first.privi,
      edits: entry.edits,
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

    json_view(["ok"])
  end

  def delete
    entry = Tlspec.load!(params["ukey"])

    unless _cvuser.privi > 2 || entry.edits.first.uname == _cvuser.uname
      return halt! 403, "Bạn không đủ quyền hạn để xoá!"
    end

    entry.delete!

    json_view(["ok"])
  end
end
