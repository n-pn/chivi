require "./_ys_ctrl_base"
require "../data/ysbook"

class YS::CritCtrl < AC::Base
  base "/_ys/crits"

  # list revies
  @[AC::Route::GET("/")]
  def index(sort : String = "utime",
            smin : Int32 = 3, smax : Int32 = 5,
            from : String = "ys", user : String? = nil,
            book : Int32? = nil, list : Int32? = nil,
            vtag : String? = nil)
    pg_no, limit, offset = _paginate(max: 24)

    query = Yscrit.query.sort_by(sort).where("vhtml <> ''")

    query.where("? = any(vtags)", vtag) if vtag
    query.where("ysuser_id = ?", user) if user

    query.where("stars >= ?", smin) if smin > 1
    query.where("stars <= ?", smax) if smax < 5

    query.limit(limit).offset(offset)

    if book
      crits = query.where("nvinfo_id = ?", book).to_a
      total = Ysbook.crit_count(book)
    elsif list
      yslist = Yslist.find!({id: list})
      total = yslist.book_count
      crits = query.where("yslist_id = ?", yslist.id).to_a
    else
      total = query.dup.limit((pg_no &+ 2) &* limit).offset(0).count.to_i
      crits = query.to_a
    end

    books = Wninfo.preload(crits.map(&.nvinfo_id))
    users = Ysuser.preload(crits.map(&.ysuser_id))

    lists = yslist ? [yslist] : Yslist.preload(crits.compact_map(&.yslist_id))

    total = offset &+ crits.size if total < offset &+ crits.size

    pgmax = _pgidx(total, limit)
    pgmax += 1 if pgmax == pg_no && crits.size == limit

    render json: ({
      crits: CritView.as_list(crits),
      books: BookView.as_hash(books),
      lists: ListView.as_hash(lists),
      users: UserView.as_hash(users),
      pgidx: pg_no,
      total: total,
      pgmax: pgmax,
    })
  end

  @[AC::Route::GET("/:crit_id")]
  def show(crit_id : Int32)
    ycrit = Yscrit.find!({id: crit_id})
    wn_id = ycrit.nvinfo_id
    wbook = wn_id > 0 ? Wninfo.find({id: wn_id}) : nil
    ylist = Yslist.find({id: ycrit.yslist_id})

    json = {
      crit: CritView.new(ycrit),
      book: wbook ? BookView.new(wbook) : nil,
      list: ylist ? ListView.new(ylist) : nil,
      user: UserView.new(Ysuser.find!({id: ycrit.ysuser_id})),
    }

    render json: json
  rescue ex
    Log.error(exception: ex) { ex }
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/:crit_id/:type")]
  def show_body(crit_id : Int32, type : String)
    ycrit = Yscrit.find!({id: crit_id})
    response.headers["X-WN_ID"] = ycrit.nvinfo_id.to_s

    case type
    when "ztext" then text = ycrit.ztext
    when "ms_vi" then text = ycrit.load_btran_from_disk
    when "dl_en" then text = ycrit.load_deepl_from_disk
    else              text = ycrit.vhtml
    end

    render text: text
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end
end
