require "../_ctrl_base"

class CV::DboardCtrl < CV::BaseCtrl
  base "/_db/boards"

  @[AC::Route::GET("/", converters: {limit: ConvertLimit})]
  def index(pg pg_no : Int32, lm limit : Int32 = 24)
    offset = CtrlUtil.offset(pg_no, limit)

    query = Nvinfo.query.order_by(utime: :desc)
    total = query.dup.limit(limit * 3 + offset).count

    render json: {
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
      items: query.limit(limit).offset(offset).map { |x| DboardView.new(x) },
    }
  end

  @[AC::Route::GET("/:name")]
  def show(name : String)
    unless dboard = Nvinfo.load!(name)
      raise NotFound.new("Diễn đàn không tồn tại!")
    end

    render json: {dboard: DboardView.new(dboard)}
  end
end
