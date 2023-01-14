require "./views/list_view"
require "./views/crit_view"
require "./_ctrl_base"

class YS::ListCtrl < YS::BaseCtrl
  base "/_ys"

  # get all lists
  @[AC::Route::GET("/lists")]
  def query(sort : String = "utime", user : String? = nil,
            type : String? = nil, book : Int64? = nil,
            qs : String? = nil)
    pgidx, limit, offset = CtrlUtil.page_params(params, max_limit: 24)

    query = Yslist.sort_by(sort)
    query.filter_string(qs) if qs

    query.where("ysuser_id = ?", user.split('-', 2)[0]) if user
    query.where("klass = ?", type) if type

    if book
      query.where(<<-SQL, book)
          id in (select yslist_id from yscrits where nvinfo_id = ?)
        SQL
    end

    query.where("book_count > 0")

    total = query.dup.limit(offset &+ 2 &* limit).count
    lists = query.limit(limit).offset(offset).with_ysuser

    render json: {
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(total, limit),
      lists: lists.map { |x| ListView.new(x) },
    }
  end

  @[AC::Route::GET("/lists/:list")]
  def entry(list : String, sort : String = "utime",
            smin : Int32 = 0, smax : Int32 = 6,
            lb : String? = nil)
    yslist = Yslist.find!({id: HashUtil.decode32(list)})
    pgidx, limit, offset = CtrlUtil.page_params(params, max_limit: 20)

    crits = Yscrit.sort_by(sort).with_nvinfo

    crits.where("yslist_id = ?", yslist.id)
    crits.where("stars >= ?", smin) if smin > 1
    crits.where("stars <= ?", smax) if smax < 5

    crits.limit(limit).offset(offset)
    crits.each(&.ysuser = yslist.ysuser)

    render json: {
      ylist: ListView.new(yslist),
      yl_id: yslist.origin_id,
      crits: crits.map { |x| CritView.new(x) },
      pgmax: CtrlUtil.pgmax(yslist.book_count, limit),
      pgidx: pgidx,
    }
  rescue err
    render :not_found, text: "Đánh giá không tồn tại"
  end
end
