require "./base_ctrl"

class CV::DtpostCtrl < CV::BaseCtrl
  def index
    limit = params.fetch_int("take", min: 1, max: 24)
    pgidx = params.fetch_int("page", min: 1)
    skips = (pgidx - 1) * limit

    query = Dtpost.query.sort_by(params["sort"]? || "id")

    if dtopic = params["dtopic"]?.try { |x| Dtopic.load!(x.to_i64) }
      query.filter_topic(dtopic)
    end

    if cvuser = params["cvuser"]?.try { |x| Cvuser.load!(x) }
      query.filter_owner(cvuser)
    end

    if dtopic
      total = dtopic.post_count
    else
      total = query.dup.limit(limit * 3 + skips).offset(0).count
    end

    # TODO: load user trace

    query.with_dtopic unless dtopic
    query.with_cvuser unless cvuser
    items = query.limit(limit).offset(skips)

    cache_rule :public, 10, 60

    json_view({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      items: items.map do |x|
        x.cvuser = cvuser if cvuser
        x.dtopic = dtopic if dtopic
        DtpostView.new(x)
      end,
    })
  rescue err
    halt!(500, err.message)
  end

  def detail
    dtpost = Dtpost.load!(params["dtpost"].to_i64)
    cache_rule :public, 120, 300, dtpost.updated_at.to_s

    json_view({dtpost: DtpostView.new(dtpost, full: true)})
  rescue err
    halt!(404, "Bài viết không tồn tại!")
  end

  def create
    dboard = Dboard.load!(params["dboard"].to_i64)
    return halt!(403) unless DboardACL.dtpost_create?(dboard, _cvuser)

    dtpost = Dtpost.new({cvuser: _cvuser, dboard: dboard})
    dtpost.update_content!(params)

    json_view({dtpost: DtpostView.new(dtpost)})
  end

  def update
    dboard = Dboard.load!(params["dboard"].to_i64)
    dtpost = Dtpost.load!(params["dtpost"].to_i64)
    return halt!(403) unless DboardACL.dtpost_update?(dboard, _cvuser, dtpost)

    dtpost.update_content!(params)
    json_view({dtpost: DtpostView.new(dtpost)})
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 500, err.message
  end

  def delete
    return halt!(403) unless _cvuser.privi > 2
    Dtpost.load!(params["dtpost"].to_i64).delete
    json_view({msg: "ok"})
  end
end
