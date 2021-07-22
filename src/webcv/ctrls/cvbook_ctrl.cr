require "./base_ctrl"

class CV::CvbookCtrl < CV::BaseCtrl
  private def extract_params
    page = params.fetch_int("page", min: 1)
    take = params.fetch_int("take", min: 1, max: 24)
    {page, take, (page - 1) * take}
  end

  def index
    pgidx, limit, offset = extract_params

    query =
      Cvbook.query
        .filter_btitle(params["btitle"]?)
        .filter_author(params["author"]?)
        .filter_zseed(params["sname"]?)
        .filter_genre(params["genre"]?)

    if uname = params["uname"]?
      blist = ViMark.all_books(uname, params.fetch_str("bmark", "reading"))
      total = blist.size
      query = query.where("bhash = ANY(?)", blist)
    else
      total = query.dup.limit(offset + limit * 3).offset(0).count
    end

    query.sort_by(params.fetch_str("order", "bumped"))

    response.headers.add("Cache-Control", "public, min-fresh=180")
    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "total", total
          jb.field "pgidx", pgidx
          jb.field "pgmax", (total - 1) // limit + 1

          jb.field "books" do
            jb.array do
              query.limit(limit).offset(offset).with_author.each do |book|
                jb.object do
                  jb.field "bhash", book.bhash
                  jb.field "bslug", book.bslug

                  jb.field "btitle_zh", book.ztitle
                  jb.field "btitle_hv", book.htitle
                  jb.field "btitle_vi", book.vi_title

                  jb.field "author_zh", book.author.zname
                  jb.field "author_vi", book.author.vname

                  jb.field "genres", book.bgenres
                  jb.field "bcover", book.bcover

                  jb.field "voters", book.voters
                  jb.field "rating", book.rating / 10.0
                end
              end
            end
          end
        end
      end
    end
  rescue err
    pp err

    halt! 500, err.message
  end

  def show : Nil
    bslug = params["bslug"]

    unless bhash = NvInfo.find_by_slug(bslug)
      return halt!(404, "Quyển sách không tồn tại!")
    end

    if cu_privi > 0
      access = Time.utc.to_unix // 60
      NvOrders.set_access!(bhash, access, force: true)
      spawn { NvOrders.access.save!(clean: false) }
    end

    response.headers.add("Cache-Control", "min-fresh=60")
    nvinfo = NvInfo.load(bhash)

    render_json do |res|
      JSON.build(res) do |jb|
        Views::CvbookView.render(jb, nvinfo, full: true)
      end
    end
  end
end
