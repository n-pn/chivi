class CV::YscritCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query = Yscrit.sort_by(params["_s"]? || "utime")
      .filter_ysuser(params.fetch_i64("by"))
      .filter_labels(params["lb"]?)

    if min_stars = params["gt"]?.try(&.to_i?)
      min_stars = 5 if min_stars > 5
      query.where("stars >= ?", min_stars)
    end

    if max_stars = params["lt"]?.try(&.to_i?)
      max_stars = 1 if max_stars < 1
      query.where("stars <= ?", max_stars)
    end

    if book_id = params["book"]?.try(&.to_i64?)
      nvinfo = Nvinfo.load!(book_id)
      query.filter_nvinfo(book_id)

      crits = query.limit(limit).offset(offset).with_yslist.with_ysuser.to_a
      total = nvinfo.ysbook.try(&.crit_count) || crits.size
      crits.each(&.nvinfo = nvinfo)
    else
      total = query.dup.limit((pgidx + 2) * limit).count
      crits = query.limit(limit).offset(offset)
        .with_nvinfo.with_yslist.with_ysuser
    end

    send_json({
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(total.to_i, limit),
      crits: crits.map { |x| YscritView.new(x) },
    })
  end

  def show
    crit_id = UkeyUtil.decode32(params["crit"])
    yscrit = Yscrit.find!({id: crit_id})
    send_json({yscrit: YscritView.new(yscrit)})
  rescue err
    halt! 404, "Đánh giá không tồn tại"
  end

  def replies
    crit_id = UkeyUtil.decode32(params["crit"])
    yscrit = Yscrit.find!({id: crit_id})

    query = Ysrepl.query.where("yscrit_id = ?", yscrit.id).with_ysuser
    send_json(query.map { |x| YsreplView.new(x) })
  rescue err
    Log.error { err }
    halt! 404, "Đánh giá không tồn tại"
  end
end
