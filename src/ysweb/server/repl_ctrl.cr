require "./views/repl_view"
require "./_ctrl_base"

module YS
  class ReplCtrl < BaseCtrl
    base "/_ys"

    @[AC::Route::GET("/crits/:crit/repls")]
    def list(crit : String, page : Int32 = 1)
      crit_id = CV::UkeyUtil.decode32(crit)
      repls = CV::Ysrepl.query.where("yscrit_id = ?", crit_id)

      limit = 25
      offset = (page &- 1) &* limit

      repls = repls.limit(limit).offset(offset)
      render json: repls.with_ysuser.map { |x| ReplView.new(x) }
    end
  end
end
