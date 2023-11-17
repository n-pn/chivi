require "./_ys_ctrl_base"
require "../data/ysbook_data"

class YS::CritCtrl < AC::Base
  base "/_ys"

  # list revies
  @[AC::Route::GET("/crits")]
  def query(sort : String = "utime",
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

  @[AC::Route::GET("/crits/:crit_id")]
  def entry(crit_id : Int32)
    render json: YscritPeek.fetch_one(crit_id)
  rescue ex
    Log.error(exception: ex) { ex }
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/crits/:crit_id/ztext")]
  def ztext(crit_id : Int32)
    ztext, wn_id = YscritPeek.get_ztext_and_wn_id(crit_id)
    response.headers["X-WN_ID"] = wn_id.to_s
    render text: ztext
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
