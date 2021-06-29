require "./base_ctrl"

class CV::BookCtrl < CV::BaseCtrl
  def index
    take = params.fetch_int("take", min: 8, max: 25)
    skip = params.fetch_int("skip", min: 0)
    query = Cvbook.query.limit(take).offset(skip)

    Cvbook.filter_btitle(query, params["btitle"]?)
    Cvbook.filter_author(query, params["author"]?)
    Cvbook.filter_genre(query, params["genre"]?)
    Cvbook.filter_zseed(query, params["sname"]?)

    Cvbook.order_by(query, params["order"]?)

    puts "Total books: #{Cvbook.total}"

    response.headers.add("Cache-Control", "public, min-fresh=180")

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "books" do
            jb.array do
              query.with_author.each do |book|
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
                  jb.field "rating", book.rating
                end
              end
            end
          end

          jb.field "total", Cvbook.total
        end
      end
    end
  end

  def user_books
    uname = params["uname"].downcase
    blist = params.fetch_str("bmark", "reading")
    matched = ViMark.all_books(uname, blist)
    list_books(matched)
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

  private def list_books(matched : Set(String)?)
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 1, max: 24)

    order = params.fetch_str("order", "access")
    total = matched ? matched.size : NvOrders.get(order).size

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "total", total

          jb.field "books" do
            jb.array do
              NvInfo.each(order, skip: skip, take: take + 1, matched: matched) do |bhash|
                Views::CvbookView.render(jb, NvInfo.load(bhash), full: false)
              end
            end
          end
        end
      end
    end
  end
end
