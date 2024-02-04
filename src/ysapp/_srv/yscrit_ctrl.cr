require "./_ys_ctrl_base"
require "../data/ysbook"
require "./yscrit_view"

class YS::CritCtrl < AC::Base
  base "/_ys/crits"

  # list revies
  @[AC::Route::GET("/")]
  def index(
    gt smin : Int32 = 0, lt smax : Int32 = 6,
    by user : String? = nil, lb vtag : String? = nil,
    wn book : Int32? = nil, bl list : Int32? = nil,
    _s sort : String = "utime"
  )
    pg_no, limit, offset = self._paginate(max: 24)

    query = Yscrit.query.sort_by(sort)

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
      crits: YscritView.as_list(crits),
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
      crit: YscritView.new(ycrit),
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
    when "vi_mt" then text = ycrit.vi_mt || ycrit.ztext
    when "vi_bd" then text = ycrit.vi_bd || ycrit.ztext
    when "vi_ms" then text = ycrit.vi_ms || ycrit.ztext
    when "en_dl" then text = ycrit.en_dl || ycrit.ztext
    when "en_bd" then text = ycrit.en_bd || ycrit.ztext
    when "en_ms" then text = ycrit.en_ms || ycrit.ztext
    else              text = ycrit.vhtml
    end

    render text: text
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end
end
