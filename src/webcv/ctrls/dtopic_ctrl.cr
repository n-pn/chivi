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
    halt!(500, "Có lỗi!")
  end

  def show
    dtopic = Dtopic.load!(params["dtopic"].to_i64)
    dtopic.update!({views: dtopic.views + 1})
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

  def create
    dboard = Dboard.load!(params["dboard"].to_i64)
    return halt!(403) unless DboardACL.dtopic_create?(dboard, _cvuser)

    dtopic = Dtopic.new({cvuser: _cvuser, dboard: dboard})

    dtopic.set_title(params["title"])
    dtopic.label_ids = params.json("labels").as_a.map(&.as_i)

    dtopic.posts = 0
    dtopic.set_utime(Time.utc.to_unix)

    dtopic.save!
    dboard.update!({posts: dboard.posts + 1})

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

    dtopic.set_title(params["title"])
    dtopic.label_ids = params.json("labels").as_a.map(&.as_i)
    dtopic.set_utime(Time.utc.to_unix)

    dtopic.save!

    json_view do |jb|
      jb.object {
        jb.field "dtopic" { DtopicView.render(jb, dtopic, dboard) }
      }
    end
  end
end
