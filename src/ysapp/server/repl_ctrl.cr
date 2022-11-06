require "./views/repl_view"
require "./_ctrl_base"

module YS
  class ReplCtrl < BaseCtrl
    base "/_ys"

    @[AC::Route::GET("/crits/:crit/repls")]
    def list(crit : String, page : Int32 = 1)
      crit_id = CV::UkeyUtil.decode32(crit)
      repls = Ysrepl.query.where("yscrit_id = ?", crit_id)

      limit = 25
      offset = (page &- 1) &* limit

      repls = repls.limit(limit).offset(offset)
      render json: repls.with_ysuser.map { |x| ReplView.new(x) }
    end
  end

  @[AC::Route::GET("/repls/:repl/raw")]
  def rawzh(repl : String)
    yrepl = Ysrepl.find!({id: CV::UkeyUtil.decode32(repl)})
    binfo = yrepl.yscrit.nvinfo
    render text: "#{binfo.dname}\t#{binfo.vname}\t#{ycrit.ztext}"
  rescue err
    render :not_found, text: "Phản hồi không tồn tại"
  end
end
