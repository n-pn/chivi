require "./_ys_ctrl_base"
require "../../_util/text_util"
require "../_raw/raw_yslist"

class YS::ListCtrl < AC::Base
  base "/_ys"

  # get all lists
  @[AC::Route::GET("/lists")]
  def query(
    sort : String = "utime", type : String? = nil,
    user : String? = nil, book : Int64? = nil,
    qs : String? = nil
  )
    pg_no, limit, offset = _paginate(max: 24)

    query = Yslist.sort_by(sort)
    query.where("klass = ?", type) if type

    query.where("ysuser_id = ?", user.split('-', 2)[0]) if user
    query.where("vslug LIKE '%-#{TextUtil.slugify(qs)}-%'") if qs

    query.where("id in (select yslist_id from yscrits where nvinfo_id = ?)", book) if book

    # query.where("book_count > 0")

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

  @[AC::Route::GET("/lists/:id")]
  def entry(id : Int32, sort : String = "utime",
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

    books = Wninfo.preload(crits.map(&.nvinfo_id))

    render json: {
      ylist: ListView.new(ylist, true),
      yuser: UserView.new(yuser),

      crits: CritView.as_list(crits, false),
      books: BookView.as_hash(books),

      pgidx: pg_no,
      pgmax: _pgidx(ylist.book_count, limit),
    }
  rescue ex
    render :not_found, text: "Thư đơn không tồn tại"
  end

  @[AC::Route::POST("/lists/info", body: :data)]
  def upsert(data : RawYslist, rtime : Int64 = Time.utc.to_unix)
    yslist = Yslist.upsert!(data, rtime: rtime)
    render text: yslist.id
  end
end
