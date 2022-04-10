require "./_base_ctrl"

class CV::CvreplCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query =
      Cvrepl.query
        .sort_by(params["sort"]? || "id")
        .where("state >= 0 AND ii > 0")

    if cvpost = params["cvpost"]?.try { |x| Cvpost.load!(x) }
      query.filter_topic(cvpost)
    end

    if cvuser = params["cvuser"]?.try { |x| Cvuser.load!(x) }
      query.filter_owner(cvuser)
    end

    if cvpost
      total = cvpost.repl_count
    else
      total = query.dup.limit(limit * 3 + offset).offset(0).count
    end

    # TODO: load user trace

    query.with_cvpost unless cvpost
    query.with_cvuser unless cvuser
    items = query.limit(limit).offset(offset)

    set_cache :public, maxage: 20

    send_json({
      tplist: {
        total: total,
        pgidx: pgidx,
        pgmax: (total - 1) // limit + 1,
        items: items.map do |x|
          x.cvuser = cvuser if cvuser
          x.cvpost = cvpost if cvpost
          CvreplView.new(x)
        end,
      },
    })
  end

  def detail
    cvrepl = Cvrepl.load!(params["cvrepl"].to_i64)
    set_cache maxage: 30

    send_json({
      id:    cvrepl.id,
      input: cvrepl.input,
      itype: cvrepl.itype,
      rp_id: cvrepl.repl_cvrepl_id,
    })
  rescue err
    halt!(404, "Bài viết không tồn tại!")
  end

  def create
    cvpost = Cvpost.load!(params["cvpost"])
    unless DboardACL.cvrepl_create?(cvpost, _cvuser)
      return halt!(403, "Bạn không có quyền tạo bình luận mới")
    end

    cvrepl = Cvrepl.new({cvuser: _cvuser, cvpost: cvpost, ii: cvpost.repl_count + 1})

    dtrepl_id = params["rp_id"]?.try(&.to_i64?) || 0_i64
    dtrepl_id = cvpost.rpbody.id if dtrepl_id == 0

    cvrepl.set_dtrepl_id(dtrepl_id)
    cvrepl.update_content!(params)
    cvpost.bump!(cvrepl.id)

    repl = Cvrepl.load!(cvrepl.repl_cvrepl_id)
    repl.update!({repl_count: repl.repl_count + 1})

    send_json({cvrepl: CvreplView.new(cvrepl)})
  end

  def update
    cvrepl = Cvrepl.load!(params["cvrepl"].to_i64)
    return halt!(403) unless DboardACL.cvrepl_update?(cvrepl, _cvuser)

    cvrepl.update_content!(params)
    send_json({cvrepl: CvreplView.new(cvrepl)})
  end

  def delete
    cvrepl = Cvrepl.load!(params["cvrepl"].to_i64)

    if _cvuser.privi == cvrepl.cvuser_id
      admin = false
    elsif _cvuser.privi > 2
      admin = true
    else
      return halt!(403, "Bạn không có quyền xoá chủ đề")
    end

    Cvrepl.load!(params["cvrepl"].to_i64).soft_delete(admin: admin)
    send_json({msg: "ok"})
  end
end
