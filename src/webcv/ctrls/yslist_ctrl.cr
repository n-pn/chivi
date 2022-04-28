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
    list_id = UkeyUtil.decode32(params["list"])
    yslist = Yslist.find!({id: list_id})
    send_json({yslist: YslistView.new(yslist, true)})
  rescue err
    halt! 404, "Đánh giá không tồn tại"
  end
end
