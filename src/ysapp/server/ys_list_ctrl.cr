require "./_ys_ctrl_base"
require "../../_util/text_util"

class YS::ListCtrl < AC::Base
  base "/_ys"

  # get all lists
  @[AC::Route::GET("/lists")]
  def query(sort : String = "utime", user : String? = nil,
            type : String? = nil, book : Int64? = nil,
            qs : String? = nil)
    pg_no, limit, offset = _paginate(max: 24)

    query = Yslist.sort_by(sort)

    if qs
      qs = TextUtil.slugify(qs)
      query.where("vslug LIKE '%-#{qs}-%'")
    end

    query.where("ysuser_id = ?", user.split('-', 2)[0]) if user
    query.where("klass = ?", type) if type

    if book
      fragment = "id in (select yslist_id from yscrits where nvinfo_id = ?)"
      query.where(fragment, book)
    end

    query.where("book_count > 0")

    total = query.dup.limit(offset &+ 2 &* limit).count
    lists = query.limit(limit).offset(offset).with_ysuser

    render json: {
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
      lists: lists.map { |x| ListView.new(x) },
    }
  end

  @[AC::Route::GET("/lists/:id", converters: {id: ConvertBase32})]
  def entry(id : Int64, sort : String = "utime",
            smin : Int32 = 0, smax : Int32 = 6,
            lb : String? = nil)
    yslist = Yslist.find!({id: id})

    crits = Yscrit.sort_by(sort)

    crits.where("yslist_id = ?", yslist.id)
    crits.where("stars >= ?", smin) if smin > 1
    crits.where("stars <= ?", smax) if smax < 5

    pg_no, limit, offset = _paginate(max: 20)
    crits.limit(limit).offset(offset)
    crits.each(&.ysuser = yslist.ysuser)

    query = crits.to_a.join(", ", &.nvinfo_id)
    books = CvBook.query.where("id in (#{query})")

    render json: {
      yl_id: yslist.origin_id,
      ylist: ListView.new(yslist),
      crits: CritView.map(crits, false),
      books: BookView.as_hash(books),
      pgmax: _pgidx(yslist.book_count, limit),
      pgidx: pg_no,
    }
  rescue err
    Log.info { err }
    render :not_found, text: "Thư đơn không tồn tại"
  end
end
