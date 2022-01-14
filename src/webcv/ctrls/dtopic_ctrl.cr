require "./base_ctrl"

class CV::DtopicCtrl < CV::BaseCtrl
  def index
    limit = params.fetch_int("take", min: 1, max: 24)
    pgidx = params.fetch_int("page", min: 1)
    skips = (pgidx - 1) * limit

    query = Dtopic.query.order_by(_sort: :desc)
    query.filter_label(params["dlabel"]?)

    dboard = params["dboard"]?.try { |x| Dboard.load!(x.to_i64) }
    cvuser = params["cvuser"]?.try { |x| Cvuser.load!(x) }

    query.filter_board(dboard)
    query.filter_owner(cvuser)

    total = query.dup.limit(limit * 3 + skips).offset(0).count

    cache_rule :public, 10, 60

    json_view do |jb|
      jb.object {
        jb.field "total", total
        jb.field "pgidx", pgidx
        jb.field "pgmax", (total - 1) // limit + 1

        jb.field "items" {
          jb.array {
            query.limit(limit).offset(skips)
            query.with_cvuser.each do |dtopic|
              dboard = dboard || dtopic.dboard
              cvuser = cvuser || dtopic.cvuser

              DtopicView.render(jb, dtopic, dboard.not_nil!, cvuser.not_nil!)
            end
          }
        }
      }
    end
  rescue err
    halt!(500, err.message)
  end

  def show
    dtopic = Dtopic.load!(params["dtopic"].to_i64)
    dtopic.bump_view_count!

    cache_rule :public, 120, 300, dtopic.updated_at.to_s
    # TODO: load user trace

    json_view do |jb|
      jb.object {
        jb.field "dtopic" { DtopicView.render(jb, dtopic) }
      }
    end
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
    populate_dtopic(dtopic)

    dtopic.save_content!
    dboard.bump_post_count!

    json_view do |jb|
      jb.object {
        jb.field "dtopic" { DtopicView.render(jb, dtopic, dboard) }
      }
    end
  end

  def update
    dboard = Dboard.load!(params["dboard"].to_i64)
    dtopic = Dtopic.load!(params["dtopic"].to_i64)
    return halt!(403) unless DboardACL.dtopic_update?(dboard, _cvuser, dtopic)

    populate_dtopic(dtopic)
    dtopic.save_content!

    json_view do |jb|
      jb.object {
        jb.field "dtopic" { DtopicView.render(jb, dtopic, dboard) }
      }
    end
  end

  private def populate_dtopic(dtopic : Dtopic)
    dtopic.set_title(params["title"])
    dtopic.dlabel_ids = params.json("labels").as_a.map(&.as_i)
    dtopic.set_utime(Time.utc.to_unix)

    dtopic.dtbody.set_input(params["body_input"], params["body_itype"])
    dtopic.brief = dtopic.dtbody.otext.split("\n", 2).first? || ""
  end
end
