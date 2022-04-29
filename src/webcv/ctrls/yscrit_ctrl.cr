require "./_base_ctrl"

class CV::YscritCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query = Yscrit.sort_by(params["sort"]?)
      .filter_ysuser(params["by"]?.try(&.to_i64?))
      .filter_labels(params["lb"]?)

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
      pgmax: CtrlUtil.pgmax(total, limit),
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
