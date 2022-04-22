require "./_base_ctrl"

class CV::YscritCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query = Yscrit.sort_by(params["sort"]?)
      .filter_ysuser(params["user"]?.try(&.to_i64?))
      .with_ysuser

    if book_id = params["book"]?.try(&.to_i64?)
      query.filter_nvinfo(book_id)

      total = query.dup.count
      crits = query.limit(limit).offset(offset).with_yslist.to_a

      if crits.size > 0
        nvinfo = Nvinfo.load!(book_id)
        crits.each(&.nvinfo = nvinfo)
      end
    elsif list_id = params["list"]?.try { |x| UkeyUtil.decode32(x) }
      query.filter_yslist(list_id)
      total = query.dup.count
      crits = query.limit(limit).offset(offset).with_nvinfo.to_a

      if crits.size > 0
        yslist = Yslist.load!(list_id)
        crits.each(&.yslist = yslist)
      end
    else
      total = query.dup.limit((pgidx + 2) * limit).count
      crits = query.limit(limit).offset(offset).with_nvinfo.with_yslist

      # if crits.size > 0
      #   nvinfos = Nvinfo.query.with_author.where("id = ANY(?)", crits.map(&.nvinfo_id))
      #   bookmap = nvinfos.map { |x| {x.id, x} }.to_h

      #   crits.each { |x| x.nvinfo = bookmap[x.nvinfo_id] }
      # end
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
