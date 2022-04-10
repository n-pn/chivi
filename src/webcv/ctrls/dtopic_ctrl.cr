require "./_base_ctrl"

class CV::CvpostCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query =
      Cvpost.query
        .order_by(_sort: :desc)
        .where("state >= -1")
        .filter_label(params["labels"]?)

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
    query.with_rpbody.with_lastrp(&.with_cvuser)
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
          CvpostView.new(x)
        },
      },
    })
  end

  def show
    cvpost = Cvpost.load!(params["cvpost"])

    cvpost.bump_view_count!
    cvpost.nvinfo.tap { |x| x.update!({view_count: x.view_count + 1}) }

    # TODO: load user trace

    set_cache :public, maxage: 20
    send_json({cvpost: CvpostView.new(cvpost, full: true)})
  rescue err
    Log.error { err }
    halt!(404, "Chủ đề không tồn tại!")
  end

  def detail
    oid = params["cvpost"]
    cvpost = Cvpost.load!(oid)

    set_cache :public, maxage: 20
    send_json({
      id:     oid,
      title:  cvpost.title,
      labels: cvpost.labels.join(","),

      body_input: cvpost.rpbody.input,
      body_itype: cvpost.rpbody.itype,
    })
  rescue err
    halt!(404, "Chủ đề không tồn tại!")
  end

  def create
    nvinfo = Nvinfo.load!(params["dboard"].to_i64)
    unless DboardACL.cvpost_create?(nvinfo, _cvuser)
      return halt!(403, "Bạn không có quyền tạo chủ đề")
    end

    count = nvinfo.post_count + 1
    cvpost = Cvpost.new({cvuser: _cvuser, nvinfo: nvinfo, ii: nvinfo.dt_ii + count})

    cvpost.update_content!(params)
    nvinfo.update!({post_count: count, board_bump: cvpost.utime})

    send_json({cvpost: CvpostView.new(cvpost)})
  end

  def update
    cvpost = Cvpost.load!(params["cvpost"])

    unless DboardACL.cvpost_update?(cvpost, _cvuser)
      return halt!(403, "Bạn không có quyền sửa chủ đề")
    end

    cvpost.update_content!(params)
    send_json({cvpost: CvpostView.new(cvpost)})
  end

  def delete
    cvpost = Cvpost.load!(params["cvpost"])

    if _cvuser.privi == cvpost.cvuser_id
      admin = false
    elsif _cvuser.privi > 2
      admin = true
    else
      return halt!(403, "Bạn không có quyền xoá chủ đề")
    end

    cvpost.soft_delete(admin: admin)
    send_json("Chủ đề đã bị xoá")
  end
end
