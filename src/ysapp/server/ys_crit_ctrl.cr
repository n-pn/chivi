require "./_ys_ctrl_base"
require "../models/ys_book"

class YS::CritCtrl < AC::Base
  base "/_ys"

  # list revies
  @[AC::Route::GET("/crits")]
  def query(sort : String = "utime",
            smin : Int32 = 1, smax : Int32 = 5,
            user : String? = nil, book : Int32? = nil, list : Int32? = nil,
            lb tags : String? = nil)
    pg_no, limit, offset = _paginate(max: 24)

    query = Yscrit.query.sort_by(sort)
    query.where("vtags @> ?", tags.split("&")) if tags
    query.where("ysuser_id = ?", user.split('-', 2)[0]) if user
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

    books = CvBook.preload(crits.map(&.nvinfo_id))
    users = Ysuser.preload(crits.map(&.ysuser_id))

    lists = yslist ? [yslist] : Yslist.preload(crits.compact_map(&.yslist_id))

    if total < offset + crits.size
      total = offset + crits.size
    end

    pgmax = _pgidx(total, limit)
    pgmax += 1 if pgmax == pg_no && crits.size == limit

    Log.info { "total: #{total}, pgmax: #{pgmax}" }

    render json: ({
      crits: CritView.as_list(crits),
      books: BookView.as_hash(books),
      lists: ListView.as_hash(lists),
      users: UserView.as_hash(users),
      pgidx: pg_no,
      total: total,
      pgmax: pgmax,
    })
  rescue err
    render json: {
      pgidx: 0,
      pgmax: 0,
      crits: [] of Yscrit,
      books: {} of Int64 => CvBook,
      error: err.message,
    }
  end

  @[AC::Route::GET("/crits/:crit_id")]
  def entry(crit_id : Int32)
    ycrit = Yscrit.find!({id: crit_id})
    yuser = Ysuser.find!({id: ycrit.ysuser_id})
    vbook = CvBook.find({id: ycrit.nvinfo_id})
    ylist = Yslist.find({id: ycrit.yslist_id})

    repls = Ysrepl.query.where("yscrit_id = ?", crit_id)
    users = Ysuser.preload(repls.map(&.ysuser_id))

    render json: {
      ycrit: CritView.new(ycrit),
      yuser: UserView.new(yuser),
      vbook: vbook ? BookView.new(vbook) : nil,
      ylist: ylist ? ListView.new(ylist) : nil,
      repls: ReplView.as_list(repls),
      users: UserView.as_hash(users),
    }
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/crits/:crit_id/ztext")]
  def ztext(crit_id : Int32)
    ycrit = Yscrit.find!({id: crit_id})

    response.headers["X-WN_ID"] = ycrit.nvinfo_id.to_s
    render text: ycrit.ztext
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/crits/:crit_id/vhtml")]
  def vhtml(crit_id : Int32)
    ycrit = Yscrit.find!({id: crit_id})
    render text: ycrit.vhtml
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/crits/:crit_id/btran")]
  def btran(crit_id : Int32)
    ycrit = Yscrit.find!({id: crit_id})
    render text: ycrit.load_btran_from_disk
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/crits/:crit_id/deepl")]
  def deepl(crit_id : Int32)
    ycrit = Yscrit.find!({id: crit_id})
    render text: ycrit.load_deepl_from_disk
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end
end
