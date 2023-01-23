require "./_ys_ctrl_base"
require "../models/ys_book"

class YS::CritCtrl < AC::Base
  base "/_ys"

  # list revies
  @[AC::Route::GET("/crits", converters: {list: ConvertBase32})]
  def query(sort : String = "utime",
            smin : Int32 = 1, smax : Int32 = 5,
            user : String? = nil, book : Int64? = nil, list : Int64? = nil,
            lb tags : String? = nil)
    # TODO: Rename lb to tags

    pg_no, limit, offset = _paginate(max: 24)

    query = Yscrit.query.sort_by(sort)
    query.where("vtags @> ?", tags.split("&")) if tags
    query.where("ysuser_id = ?", user.split('-', 2)[0]) if user
    query.where("stars >= ?", smin) if smin > 1
    query.where("stars <= ?", smax) if smax < 5
    query.limit(limit).offset(offset)

    if book
      crits = query.filter_nvinfo(book).with_yslist.with_ysuser.to_a
      total = Ysbook.query.find({nvinfo_id: book}).try(&.crit_count)
    elsif list
      yslist = Yslist.find!({id: list})
      total = yslist.book_count

      crits = query.where("yslist_id = ?", yslist.id).to_a
      crits.each(&.ysuser = yslist.ysuser)
    else
      total = query.dup.limit((pg_no &+ 2) &* limit).offset(0).count
      crits = query.with_yslist.with_ysuser
    end

    b_ids = crits.map(&.nvinfo_id)
    books = b_ids.empty? ? [] of CvBook : CvBook.query.where { id.in? b_ids }

    render json: ({
      crits: crits.map { |x| CritView.new(x) },
      books: BookView.as_hash(books),
      pgidx: pg_no,
      pgmax: _pgidx(total || b_ids.size, limit),
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

  @[AC::Route::GET("/crits/:crit_id", converters: {crit_id: ConvertBase32})]
  def entry(crit_id : Int64)
    ycrit = Yscrit.find!({id: crit_id})
    repls = Ysrepl.query.where("yscrit_id = ?", crit_id)

    vbook = CvBook.find({id: ycrit.nvinfo_id.not_nil!})
    render json: {
      entry: CritView.new(ycrit),
      vbook: vbook ? BookView.new(vbook) : nil,
      repls: repls.with_ysuser.map { |x| ReplView.new(x) },
    }
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/crits/:crit_id/ztext", converters: {crit_id: ConvertBase32})]
  def ztext(crit_id : Int64)
    ycrit = Yscrit.find!({id: crit_id})
    vdict = ycrit.vdict

    response.headers["X-DNAME"] = vdict.dname
    response.headers["X-BNAME"] = vdict.label

    render text: ycrit.ztext
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/crits/:crit_id/vhtml", converters: {crit_id: ConvertBase32})]
  def vhtml(crit_id : Int64)
    ycrit = Yscrit.find!({id: crit_id})
    render text: ycrit.vhtml
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/crits/:crit_id/btran", converters: {crit_id: ConvertBase32})]
  def btran(crit_id : Int64)
    ycrit = Yscrit.find!({id: crit_id})
    render text: ycrit.load_btran_from_disk
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end

  @[AC::Route::GET("/crits/:crit_id/deepl", converters: {crit_id: ConvertBase32})]
  def deepl(crit_id : Int64)
    ycrit = Yscrit.find!({id: crit_id})

    # res = @context.response
    # res.headers["Content-Type"] = "text/plain; charset=utf-8"

    render text: ycrit.load_deepl_from_disk
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end
end
