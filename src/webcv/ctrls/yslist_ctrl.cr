require "./_base_ctrl"

class CV::YslistCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query = Yslist.sort_by(params["_s"]? || "score")
      .filter_ysuser(params.fetch_i64("by"))
      .filter_string(params["qs"]?)

    params["class"]?.try { |klass| query.where("klass = ?", klass) }

    total = query.dup.limit((pgidx + 2) * limit).count
    lists = query.limit(limit).offset(offset).with_ysuser

    send_json({
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(total, limit),
      lists: lists.map { |x| YslistView.new(x) },
    })
  end

  def show
    yslist = Yslist.find!({id: UkeyUtil.decode32(params["list"])})

    pgidx, limit, offset = params.page_info(min: 10, max: 20)

    crits = Yscrit.sort_by(params["_s"]?).where("yslist_id = ?", yslist.id)

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

    send_json({
      ylist: YslistView.new(yslist),
      yl_id: yslist.origin_id,
      crits: crits.map { |x| YscritView.new(x) },
      pgmax: CtrlUtil.pgmax(yslist.book_count, limit),
      pgidx: pgidx,
    })
  rescue err
    halt! 404, "Đánh giá không tồn tại"
  end
end
