require "../../appcv/ys_list"
require "../../appcv/ys_crit"

require "./views/yslist_view"
require "./views/yscrit_view"
require "./_ctrl_base"

module YS
  class YslistCtrl < BaseCtrl
    base "/_ys"

    # get all lists
    @[AC::Route::GET("/lists")]
    def index(_s : String = "utime", by : Int64? = nil, qs : String? = nil)
      pgidx, limit, offset = CtrlUtil.page_params(params, max_limit: 24)
      query = CV::Yslist.sort_by(_s).filter_ysuser(by).filter_string(qs)
      query.where("book_count > 0")

      params["class"]?.try { |klass| query.where("klass = ?", klass) }

      total = query.dup.limit((pgidx &+ 2) * limit).count
      lists = query.limit(limit).offset(offset).with_ysuser

      render json: {
        pgidx: pgidx,
        pgmax: CtrlUtil.pgmax(total, limit),
        lists: lists.map { |x| YslistView.new(x) },
      }
    end

    @[AC::Route::GET("/lists/:list_id")]
    def show(list_id : String, _s : String = "utime")
      yslist = CV::Yslist.find!({id: CV::UkeyUtil.decode32(list_id)})
      pgidx, limit, offset = CtrlUtil.page_params(params, max_limit: 20)

      crits = CV::Yscrit.sort_by(_s).where("yslist_id = ?", yslist.id)

      if min_stars = params["gt"]?.try(&.to_i?)
        min_stars = 5 if min_stars > 5
        crits.where("stars >= ?", min_stars)
      end

      if max_stars = params["lt"]?.try(&.to_i?)
        max_stars = 1 if max_stars < 1
        crits.where("stars <= ?", max_stars)
      end

      crits.limit(limit).offset(offset).with_nvinfo
      crits.each(&.ysuser = yslist.ysuser)

      render json: {
        ylist: YslistView.new(yslist),
        yl_id: yslist.origin_id,
        crits: crits.map { |x| YscritView.new(x) },
        pgmax: CtrlUtil.pgmax(yslist.book_count, limit),
        pgidx: pgidx,
      }
    rescue err
      render :not_found, text: "Đánh giá không tồn tại"
    end
  end
end
