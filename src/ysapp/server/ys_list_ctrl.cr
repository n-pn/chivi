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
    lists = query.limit(limit).offset(offset).to_a

    users = Ysuser.preload(lists.map(&.ysuser_id))

    render json: {
      lists: ListView.as_list(lists, true),
      users: UserView.as_hash(users),
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end

  @[AC::Route::GET("/lists/:id", converters: {id: ConvertBase32})]
  def entry(id : Int64, sort : String = "utime",
            smin : Int32 = 0, smax : Int32 = 6,
            lb : String? = nil)
    pg_no, limit, offset = _paginate(max: 20)

    ylist = Yslist.find!({id: id})
    yuser = Ysuser.find!({id: ylist.ysuser_id})

    crits = Yscrit.sort_by(sort)

    crits.where("yslist_id = ?", ylist.id)
    crits.where("stars >= ?", smin) if smin > 1
    crits.where("stars <= ?", smax) if smax < 5

    crits.limit(limit).offset(offset).to_a

    books = CvBook.preload(crits.map(&.nvinfo_id))

    render json: {
      ylist: ListView.new(ylist),
      yuser: UserView.new(yuser),
      crits: CritView.as_list(crits, false),
      books: BookView.as_hash(books),
      pgidx: pg_no,
      pgmax: _pgidx(ylist.book_count, limit),
    }
  rescue ex
    render :not_found, text: "Thư đơn không tồn tại"
  end
end
