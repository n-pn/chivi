require "./views/repl_view"
require "./_ctrl_base"

module YS
  class ReplCtrl < BaseCtrl
    base "/_ys"

    @[AC::Route::GET("/crits/:crit/repls")]
    def list(crit : String, page : Int32 = 1)
      crit_id = HashUtil.decode32(crit)
      repls = Ysrepl.query.where("yscrit_id = ?", crit_id)

      limit = 25
      offset = (page &- 1) &* limit

      repls = repls.limit(limit).offset(offset)
      render json: repls.with_ysuser.map { |x| ReplView.new(x) }
    end
  end

  @[AC::Route::GET("/repls/:repl/ztext")]
  def ztext(crit : String)
    yrepl = Ysrepl.find!({id: HashUtil.decode32(repl)})
    vdict = Helpers.get_dict(yrepl.yscrit.nvinfo_id.to_i)

    res = @context.response
    res.headers["Content-Type"] = "text/plain; charset=utf-8"
    res.headers["X-DNAME"] = vdict.name
    res.headers["X-BNAME"] = vdict.label

    res.print yrepl.ztext
  rescue err
    render :not_found, text: "Phản hồi không tồn tại"
  end
end
