require "./base_ctrl"

class CV::YscritCtrl < CV::BaseCtrl
  def index
    page = params.fetch_int("page", min: 1)
    take = params.fetch_int("take", min: 1, max: 20)
    skip = (page - 1) &* take

    query = Yscrit.sort_by(params["sort"]?)
      .filter_ysuser(params["user"]?.try(&.to_i64?))
      .with_ysuser

    if book_id = params["book"]?.try(&.to_i64?)
      query.filter_nvinfo(book_id)

      total = query.dup.count
      crits = query.limit(take).offset(skip).to_a

      if crits.size > 0
        nvinfo = Nvinfo.load!(book_id)
        crits.each { |x| x.nvinfo = nvinfo }
      end
    else
      total = query.dup.limit((page + 2) * take).count
      crits = query.limit(take).offset(skip).to_a

      if crits.size > 0
        nvinfos = Nvinfo.query.with_author.where("id = ANY(?)", crits.map(&.nvinfo_id))
        bookmap = nvinfos.map { |x| {x.id, x} }.to_h

        crits.each { |x| x.nvinfo = bookmap[x.nvinfo_id] }
      end
    end

    render_json({
      pgidx: page,
      pgmax: pgmax(total, take),
      crits: crits.map { |x| YscritView.new(x) },
    })
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 500, err.message
  end

  def show
    crit_id = UkeyUtil.decode32(params["crit"])
    yscrit = Yscrit.find!({id: crit_id})
    render_json(YscritView.new(yscrit))
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 404, "Đánh giá không tồn tại"
  end

  def replies
    crit_id = UkeyUtil.decode32(params["crit"])
    yscrit = Yscrit.find!({id: crit_id})

    query = Ysrepl.query.where("yscrit_id = ?", yscrit.id).with_ysuser
    render_json(query.map { |x| YsreplView.new(x) })
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 404, "Đánh giá không tồn tại"
  end
end
