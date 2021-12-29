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

    zhbooks = nvinfo.zhbooks.to_a.sort_by(&.zseed)
    if zhbooks.empty? || zhbooks.first.zseed != 0
      zhbooks.unshift(Zhbook.load!(nvinfo, 0))
    else
      base_zhbook = zhbooks[0]
      base_zhbook.copy_newers!(zhbooks[1..]) if base_zhbook.staled?
    end

    if (ubmemo.lr_sname.empty?) && (zhbook = zhbooks.first?)
      if chinfo = zhbook.chinfo(0)
        ubmemo.lr_chidx = -1
        ubmemo.lc_title = chinfo.title
        ubmemo.lc_uslug = chinfo.uslug
      end
    end

    response.headers.add("Cache-Control", "min-fresh=30")

    json_view do |jb|
      jb.object {
        jb.field "nvinfo" { NvinfoView.render(jb, nvinfo, full: true) }
        jb.field "ubmemo" { UbmemoView.render(jb, ubmemo) }

        jb.field "chseed" do
          jb.array do
            zhbooks.each do |zhbook|
              jb.object {
                jb.field "sname", zhbook.sname
                jb.field "snvid", zhbook.snvid
                # jb.field "wlink", zhbook.wlink
                jb.field "utime", zhbook.utime
                jb.field "chaps", zhbook.chap_count
                jb.field "_type", zhbook._type
              }
            end
          end
        end
      }
    end
  rescue err
    Log.error { err.message.colorize.red }
    halt! 500, "Có lỗi từ hệ thống"
  end
end
