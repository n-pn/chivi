require "../_ctrl_base"

class CV::DboardCtrl < CV::BaseCtrl
  base "/_db/boards"

  @[AC::Route::GET("/")]
  def index
    pg_no, limit, offset = _paginate(min: 24, max: 100)

    query = Wninfo.query.order_by(utime: :desc)
    total = query.dup.limit(limit * 3 + offset).count

    render json: {
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
      items: query.limit(limit).offset(offset).map { |x| DboardView.new(x) },
    }
  end

  @[AC::Route::GET("/:wm_id")]
  def show(wm_id : Int32)
    unless dboard = Wninfo.load!(wm_id)
      raise NotFound.new("Diễn đàn không tồn tại!")
    end

    render json: DboardView.new(dboard)
  end
end
