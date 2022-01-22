require "./base_ctrl"

class CV::DtopicCtrl < CV::BaseCtrl
  def index
    limit = params.fetch_int("take", min: 1, max: 24)
    pgidx = params.fetch_int("page", min: 1)
    skips = (pgidx - 1) * limit

    query = Dtopic.query.order_by(_sort: :desc)
    query.filter_label(params["dlabel"]?)

    if dboard = params["dboard"]?.try { |x| Dboard.load!(x.to_i64) }
      query.filter_board(dboard)
    end

    if cvuser = params["cvuser"]?.try { |x| Cvuser.load!(x) }
      query.filter_owner(cvuser)
    end

    total = query.dup.limit(limit * 3 + skips).offset(0).count

    query.with_dboard unless dboard
    query.with_cvuser unless cvuser
    items = query.limit(limit).offset(skips).to_a

    cache_rule :public, 10, 60

    json_view({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      items: items.map do |x|
        x.cvuser = cvuser if cvuser
        x.dboard = dboard if dboard
        DtopicView.new(x)
      end,
    })
  rescue err
    halt!(500, err.message)
  end

  def show
    dtopic = Dtopic.load!(params["dtopic"].to_i64)
    dtopic.bump_view_count!

    cache_rule :public, 120, 300, dtopic.updated_at.to_s
    # TODO: load user trace

    json_view({dtopic: DtopicView.new(dtopic, full: true)})
  rescue err
    halt!(404, "Chủ đề không tồn tại!")
  end

  def detail
    dtopic = Dtopic.load!(params["dtopic"].to_i64)

    json_view({
      id: dtopic.id,

      title:  dtopic.title,
      labels: dtopic.dlabel_ids,

      body_input: dtopic.dtbody.input,
      body_itype: dtopic.dtbody.itype,
    })
  rescue err
    halt!(404, "Chủ đề không tồn tại!")
  end

  def create
    dboard = Dboard.load!(params["dboard"].to_i64)
    return halt!(403) unless DboardACL.dtopic_create?(dboard, _cvuser)

    dtopic = Dtopic.new({cvuser: _cvuser, dboard: dboard})
    dtopic.update_content!(params)

    json_view({dtopic: DtopicView.new(dtopic)})
  end

  def update
    dboard = Dboard.load!(params["dboard"].to_i64)
    dtopic = Dtopic.load!(params["dtopic"].to_i64)
    return halt!(403) unless DboardACL.dtopic_update?(dboard, _cvuser, dtopic)

    dtopic.update_content!(params)
    json_view({dtopic: DtopicView.new(dtopic)})
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 500, err.message
  end

  def delete
    return halt!(403) unless _cvuser.privi > 2
    Dtopic.load!(params["dtopic"].to_i64).delete
    json_view({msg: "ok"})
  end
end
