require "./views/crit_view"
require "./views/repl_view"
require "./_ctrl_base"

module YS
  class CritCtrl < BaseCtrl
    base "/_ys"

    # list revies
    @[AC::Route::GET("/crits")]
    def query(sort : String = "utime", user : String? = nil,
              smin : Int32 = 0, smax : Int32 = 6,
              book : Int64? = nil, list : String? = nil,
              lb : String? = nil)
      # TODO: Rename lb to tags
      pgidx, limit, offset = CtrlUtil.page_params(params, max_limit: 24)

      query = Yscrit.sort_by(sort).filter_labels(lb)
      query = query.filter_ysuser(user.split('-', 2).first?) if user

      query.where("stars >= ?", smin) if smin > 1
      query.where("stars <= ?", smax) if smax < 5
      query.limit(limit).offset(offset)

      if book
        nvinfo = CV::Nvinfo.load!(book)
        total = nvinfo.ysbook.try(&.crit_count) || 0

        crits = query.filter_nvinfo(book).with_yslist.with_ysuser.to_a
        crits.each(&.nvinfo = nvinfo)
      elsif list
        yslist = Yslist.find!({id: UkeyUtil.decode32(list)})
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

    @[AC::Route::GET("/crits/:crit_id", converters: {crit_id: Base32ID})]
    def entry(crit_id : Int64)
      ycrit = Yscrit.find!({id: crit_id})
      repls = Ysrepl.query.where("yscrit_id = ?", crit_id)

      render json: {
        entry: CritView.new(ycrit),
        repls: repls.with_ysuser.map { |x| ReplView.new(x) },
      }
    rescue err
      render :not_found, text: "Đánh giá không tồn tại"
    end

    @[AC::Route::GET("/crits/:crit_id/ztext", converters: {crit_id: Base32ID})]
    def ztext(crit_id : Int64)
      ycrit = Yscrit.find!({id: crit_id})
      vdict = Helpers.load_dict(ycrit.nvinfo_id.try(&.to_i) || 0)

      @render_called = true
      res = @context.response

      res.headers["Content-Type"] = "text/plain; charset=utf-8"
      res.headers["X-DNAME"] = vdict.name
      res.headers["X-BNAME"] = vdict.label

      res.print ycrit.ztext
    rescue err
      render :not_found, text: "Đánh giá không tồn tại"
    end

    @[AC::Route::GET("/crits/:crit_id/vhtml", converters: {crit_id: Base32ID})]
    def vhtml(crit_id : Int64)
      ycrit = Yscrit.find!({id: crit_id})
      render text: ycrit.vhtml
    rescue err
      render :not_found, text: "Đánh giá không tồn tại"
    end

    @[AC::Route::GET("/crits/:crit_id/btran", converters: {crit_id: Base32ID})]
    def btran(crit_id : Int64)
      ycrit = Yscrit.find!({id: crit_id})
      render text: ycrit.load_btran_from_disk
    rescue err
      render :not_found, text: "Đánh giá không tồn tại"
    end

    @[AC::Route::GET("/crits/:crit_id/deepl", converters: {crit_id: Base32ID})]
    def deepl(crit_id : Int64)
      ycrit = Yscrit.find!({id: crit_id})

      # res = @context.response
      # res.headers["Content-Type"] = "text/plain; charset=utf-8"

      render text: ycrit.load_deepl_from_disk
    rescue err
      render :not_found, text: "Đánh giá không tồn tại"
    end
  end
end
