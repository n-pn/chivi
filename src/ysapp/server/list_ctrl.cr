require "./views/list_view"
require "./views/crit_view"
require "./_ctrl_base"

module YS
  class ListCtrl < BaseCtrl
    base "/_ys"

    # get all lists
    @[AC::Route::GET("/lists")]
    def query(sort : String = "utime", user : String? = nil,
              type : String? = nil, book : Int64? = nil,
              qs : String? = nil)
      pgidx, limit, offset = CtrlUtil.page_params(params, max_limit: 24)

      query = Yslist.sort_by(sort).filter_string(qs)
      query.filter_ysuser(user.split('-', 2).first) if user
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
    def entry(list : String, sort : String = "utime")
      yslist = Yslist.find!({id: UkeyUtil.decode32(list)})
      pgidx, limit, offset = CtrlUtil.page_params(params, max_limit: 20)

      crits = Yscrit.sort_by(sort).where("yslist_id = ?", yslist.id)
      crits.limit(limit).offset(offset).with_nvinfo
      crits.each(&.ysuser = yslist.ysuser)

      if min_stars = params["smin"]?.try(&.to_i?)
        crits.where("stars >= ?", min_stars) if min_stars > 1
      end

      if max_stars = params["smax"]?.try(&.to_i?)
        crits.where("stars <= ?", max_stars) if max_stars < 5
      end

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
end
