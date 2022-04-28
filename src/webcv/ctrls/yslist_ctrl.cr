require "./_base_ctrl"

class CV::YslistCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query = Yslist.sort_by(params["_s"]?)
      .filter_ysuser(params["by"]?.try(&.to_i64?))
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

    crits = Yscrit.sort_by(params["_s"]?)
      .where("yslist_id = ?", yslist.id)
      .limit(limit).offset(offset).with_nvinfo
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
