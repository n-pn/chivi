require "./_base_ctrl"

class CV::DtpostCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query =
      Dtpost.query
        .sort_by(params["sort"]? || "id")
        .where("state >= 0 AND ii > 0")

    if dtopic = params["dtopic"]?.try { |x| Dtopic.load!(x) }
      query.filter_topic(dtopic)
    end

    if cvuser = params["cvuser"]?.try { |x| Cvuser.load!(x) }
      query.filter_owner(cvuser)
    end

    if dtopic
      total = dtopic.post_count
    else
      total = query.dup.limit(limit * 3 + offset).offset(0).count
    end

    # TODO: load user trace

    query.with_dtopic unless dtopic
    query.with_cvuser unless cvuser
    items = query.limit(limit).offset(offset)

    set_cache :public, maxage: 20

    send_json({
      dtlist: {
        total: total,
        pgidx: pgidx,
        pgmax: (total - 1) // limit + 1,
        items: items.map do |x|
          x.cvuser = cvuser if cvuser
          x.dtopic = dtopic if dtopic
          DtpostView.new(x)
        end,
      },
    })
  end

  def detail
    dtpost = Dtpost.load!(params["dtpost"].to_i64)
    set_cache maxage: 30

    send_json({
      id:    dtpost.id,
      input: dtpost.input,
      itype: dtpost.itype,
      rp_id: dtpost.repl_dtpost_id,
    })
  rescue err
    halt!(404, "Bài viết không tồn tại!")
  end

  def create
    dtopic = Dtopic.load!(params["dtopic"])
    unless DboardACL.dtpost_create?(dtopic, _cvuser)
      return halt!(403, "Bạn không có quyền tạo bình luận mới")
    end

    dtpost = Dtpost.new({cvuser: _cvuser, dtopic: dtopic, ii: dtopic.post_count + 1})

    dtrepl_id = params["rp_id"]?.try(&.to_i64?) || 0_i64
    dtrepl_id = dtopic.dtbody.id if dtrepl_id == 0

    dtpost.set_dtrepl_id(dtrepl_id)
    dtpost.update_content!(params)

    dtopic.bump_post_count!
    repl = Dtpost.load!(dtpost.repl_dtpost_id)
    repl.update!({repl_count: repl.repl_count + 1})

    send_json({dtpost: DtpostView.new(dtpost)})
  end

  def update
    dtpost = Dtpost.load!(params["dtpost"].to_i64)
    return halt!(403) unless DboardACL.dtpost_update?(dtpost, _cvuser)

    dtpost.update_content!(params)
    send_json({dtpost: DtpostView.new(dtpost)})
  end

  def delete
    dtpost = Dtpost.load!(params["dtpost"].to_i64)

    if _cvuser.privi == dtpost.cvuser_id
      admin = false
    elsif _cvuser.privi > 2
      admin = true
    else
      return halt!(403, "Bạn không có quyền xoá chủ đề")
    end

    Dtpost.load!(params["dtpost"].to_i64).soft_delete(admin: admin)
    send_json({msg: "ok"})
  end
end
