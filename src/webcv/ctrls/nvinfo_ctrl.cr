require "./base_ctrl"

class CV::NvinfoCtrl < CV::BaseCtrl
  private def extract_params
    page = params.fetch_int("page", min: 1)
    take = params.fetch_int("take", min: 1, max: 25)
    {page, take, (page - 1) * take}
  end

  def index
    Log.info { params.to_h }
    pgidx, limit, offset = extract_params

    query =
      Nvinfo.query
        .filter_btitle(params["btitle"]?)
        .filter_author(params["author"]?)
        .filter_zseed(params["sname"]?)
        .filter_genre(params["genre"]?)
        .filter_cvuser(params["uname"]?, params["bmark"]?)

    total = query.dup.limit(offset + limit * 3).offset(0).count

    query.sort_by(params.fetch_str("order", "access"))
    response.headers.add("Cache-Control", "public, min-fresh=180")

    json_view do |jb|
      jb.object {
        jb.field "total", total
        jb.field "pgidx", pgidx
        jb.field "pgmax", (total - 1) // limit + 1

        jb.field "books" {
          jb.array {
            limit = limit == 24 ? 25 : limit
            query.limit(limit).offset(offset).with_author.each do |book|
              NvinfoView.render(jb, book, full: false)
            end
          }
        }
      }
    end
  rescue err
    Log.error { err.message }
    halt! 500, err.message
  end

  def show : Nil
    unless nvinfo = Nvinfo.find({bslug: params["bslug"]})
      return halt!(404, "Quyển sách không tồn tại!")
    end

    nvinfo.bump! if u_privi >= 0
    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo.id)

    if ubmemo.lr_chidx == 0
      lr_zseed = nvinfo.zseed_ids.find(0, &.> 0)
      zhbook = Zhbook.load!(nvinfo.id, lr_zseed)

      if chinfo = zhbook.chinfo(0)
        ubmemo.lr_chidx = -1
        ubmemo.lc_title = chinfo.title
        ubmemo.lc_uslug = chinfo.uslug
      end
    end

    response.headers.add("Cache-Control", "min-fresh=30")

    json_view do |jb|
      jb.object {
        jb.field "cvbook" { NvinfoView.render(jb, nvinfo, full: true) }
        jb.field "ubmemo" { UbmemoView.render(jb, ubmemo) }
      }
    end
  rescue err
    Log.error { err.message.colorize.red }
    halt! 500, "Có lỗi từ hệ thống"
  end
end
