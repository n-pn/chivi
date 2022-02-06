require "./_base_ctrl"

class CV::DtopicCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query =
      Dtopic.query
        .order_by(_sort: :desc)
        .where("state >= -1")
        .filter_label(params["dlabel"]?)

    if nvinfo = params["dboard"]?.try { |x| Nvinfo.load!(x.to_i64) }
      query.filter_board(nvinfo)
    else
      query.where("_sort > 0")
    end

    if cvuser = params["cvuser"]?.try { |x| Cvuser.load!(x) }
      query.filter_owner(cvuser)
    end

    total = query.dup.limit(limit * 3 + offset).offset(0).count

    query.with_nvinfo unless nvinfo
    query.with_cvuser unless cvuser
    items = query.limit(limit).offset(offset).to_a

    set_cache :public, maxage: 20

    send_json({
      dtlist: {
        total: total,
        pgidx: pgidx,
        pgmax: (total - 1) // limit + 1,
        items: items.map { |x|
          x.nvinfo = nvinfo if nvinfo
          x.cvuser = cvuser if cvuser
          DtopicView.new(x)
        },
      },
    })
  end

  def show
    dtopic = Dtopic.load!(params["dtopic"])

    dtopic.bump_view_count!
    dtopic.nvinfo.tap { |x| x.update!({dt_view_count: x.dt_view_count + 1}) }

    # TODO: load user trace

    set_cache :public, maxage: 20
    send_json({dtopic: DtopicView.new(dtopic, full: true)})
  rescue err
    Log.error { err }
    halt!(404, "Chủ đề không tồn tại!")
  end

  def detail
    oid = params["dtopic"]
    dtopic = Dtopic.load!(oid)

    set_cache :public, maxage: 20
    send_json({
      id:     oid,
      title:  dtopic.title,
      labels: dtopic.dlabel_ids.join(","),

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

    count = nvinfo.dtopic_count + 1
    dtopic = Dtopic.new({cvuser: _cvuser, nvinfo: nvinfo, ii: nvinfo.dt_ii + count})

    dtopic.update_content!(params)
    nvinfo.update!({dtopic_count: count, dt_post_utime: dtopic.utime})

    send_json({dtopic: DtopicView.new(dtopic)})
  end

  def update
    dtopic = Dtopic.load!(params["dtopic"])

    unless DboardACL.dtopic_update?(dtopic, _cvuser)
      return halt!(403, "Bạn không có quyền sửa chủ đề")
    end

    dtopic.update_content!(params)
    send_json({dtopic: DtopicView.new(dtopic)})
  end

  def delete
    dtopic = Dtopic.load!(params["dtopic"])

    if _cvuser.privi == dtopic.cvuser_id
      admin = false
    elsif _cvuser.privi > 2
      admin = true
    else
      return halt!(403, "Bạn không có quyền xoá chủ đề")
    end

    dtopic.soft_delete(admin: admin)
    send_json("Chủ đề đã bị xoá")
  end
end
