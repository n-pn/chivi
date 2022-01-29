require "./base_ctrl"

class CV::DboardCtrl < CV::BaseCtrl
  def index
    limit = params.fetch_int("take", min: 1, max: 24)
    pgidx = params.fetch_int("page", min: 1)
    skips = (pgidx - 1) * limit

    query = Nvinfo.query.order_by(utime: :desc)
    total = query.dup.limit(limit * 3 + skips).offset(0).count

    cache_rule :public, 30, 120

    json_view({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      items: query.limit(limit).offset(skips).map { |x| DboardView.new(x) },
    })
  end

  def show
    dboard = Nvinfo.load!(params["dboard"])

    # TODO: load user impression
    cache_rule :public, 120, 300, dboard.updated_at.to_s

    json_view({dboard: DboardView.new(dboard)})
  rescue err
    halt!(404, "Diễn đàn không tồn tại!")
  end
end
