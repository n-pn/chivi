class CV::DboardCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query = Nvinfo.query.order_by(utime: :desc)
    total = query.dup.limit(limit * 3 + offset).count

    set_cache :private, maxage: 30
    send_json({
      total: total,
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(total, limit),
      items: query.limit(limit).offset(offset).map { |x| DboardView.new(x) },
    })
  end

  def show
    unless dboard = Nvinfo.load!(params["bslug"])
      return halt!(404, "Diễn đàn không tồn tại!")
    end

    # TODO: load user impression
    set_cache :private, maxage: 120
    send_json({dboard: DboardView.new(dboard)})
  end
end
