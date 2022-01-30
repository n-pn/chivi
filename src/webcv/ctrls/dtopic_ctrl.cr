require "./base_ctrl"

class CV::DtopicCtrl < CV::BaseCtrl
  def index
    limit = params.fetch_int("take", min: 1, max: 24)
    pgidx = params.fetch_int("page", min: 1)
    offset = (pgidx - 1) * limit

    query =
      Dtopic.query
        .order_by(_sort: :desc)
        .where("state >= -1")
        .filter_label(params["dlabel"]?)

    if nvinfo = params["dboard"]?.try { |x| Nvinfo.load!(x.to_i64) }
      query.filter_board(nvinfo)
    end

    if cvuser = params["cvuser"]?.try { |x| Cvuser.load!(x) }
      query.filter_owner(cvuser)
    end

    total = query.dup.limit(limit * 3 + offset).offset(0).count

    query.with_nvinfo unless nvinfo
    query.with_cvuser unless cvuser
    items = query.limit(limit).offset(offset).to_a

    cache_rule :public, 10, 60

    json_view({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      items: items.map { |x|
        x.nvinfo = nvinfo if nvinfo
        x.cvuser = cvuser if cvuser
        DtopicView.new(x)
      },
    })
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt!(500, err.message)
  end

  def show
    dtopic = Dtopic.load!(params["dtopic"].to_i64)
    dtopic.bump_view_count!
    dtopic.nvinfo.tap { |x| x.update!({dt_view_count: x.dt_view_count + 1}) }

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
    nvinfo = Nvinfo.load!(params["dboard"].to_i64)
    unless DboardACL.dtopic_create?(nvinfo, _cvuser)
      return halt!(403, "Bạn không có quyền tạo chủ đề")
    end

    ii = nvinfo.dtopic_count + 1
    dtopic = Dtopic.new({cvuser: _cvuser, nvinfo: nvinfo, ii: ii})
    dtopic.update_content!(params)
    nvinfo.update!({dtopic_count: ii, dt_post_utime: dtopic.utime})

    json_view({dtopic: DtopicView.new(dtopic)})
  end

  def update
    dtopic = Dtopic.load!(params["dtopic"].to_i64)

    unless DboardACL.dtopic_update?(dtopic, _cvuser)
      return halt!(403, "Bạn không có quyền sửa chủ đề")
    end

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
