require "./views/crit_view"
require "./views/repl_view"
require "./_ctrl_base"

module YS
  class CritCtrl < BaseCtrl
    base "/_ys"

    # list revies
    @[AC::Route::GET("/crits")]
    def query(sort : String = "utime", user : Int64? = nil,
              smin : Int32 = 0, smax : Int32 = 6,
              book : Int64? = nil, list : String? = nil,
              tags : String? = nil)
      pgidx, limit, offset = CtrlUtil.page_params(params, max_limit: 24)

      query = CV::Yscrit.sort_by(sort).filter_ysuser(user).filter_labels(tags)
      query.where("stars >= ?", smin) if smin > 0
      query.where("stars <= ?", smax) if smax < 6
      query.limit(limit).offset(offset)

      if book
        nvinfo = CV::Nvinfo.load!(book)
        total = nvinfo.ysbook.try(&.crit_count) || 0

        crits = query.filter_nvinfo(book).with_yslist.with_ysuser.to_a
        crits.each(&.nvinfo = nvinfo)
      elsif list
        yslist = CV::Yslist.find!({id: CV::UkeyUtil.decode32(list)})
        total = yslist.book_count

        crits = query.where("yslist_id = ?", yslist.id).with_nvinfo.to_a
        crits.each(&.ysuser = yslist.ysuser)
      else
        total = query.dup.limit((pgidx &+ 2) &* limit).offset(0).count
        crits = query.with_nvinfo.with_yslist.with_ysuser
      end

      render json: {
        pgidx: pgidx,
        pgmax: CtrlUtil.pgmax(total, limit),
        crits: crits.map { |x| CritView.new(x) },
      }
    end

    @[AC::Route::GET("/crits/:crit")]
    def entry(crit : String)
      ycrit = CV::Yscrit.find!({id: CV::UkeyUtil.decode32(crit)})
      repls = CV::Ysrepl.query.where("yscrit_id = ?", ycrit.id)

      render json: {
        ycrit: CritView.new(ycrit),
        repls: repls.with_ysuser.map { |x| ReplView.new(x) },
      }
    rescue err
      render :not_found, text: "Đánh giá không tồn tại"
    end
  end
end
