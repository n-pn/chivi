require "./base_ctrl"

class CV::DtopicCtrl < CV::BaseCtrl
  def index
    limit = params.fetch_int("take", min: 1, max: 24)
    pgidx = params.fetch_int("page", min: 1)
    skips = (pgidx - 1) * limit

    query = Dtopic.query.order_by(_sort: :desc)

    if dboard_id = params["dboard"]?
      dboard = Dboard.load!(dboard_id.to_i64)
    end

    if user_name = params["cvuser"]?
      cvuser = Cvuser.load!(user_name)
    end

    query = dboard ? query.where({dboard_id: dboard.not_nil!.id}) : query.with_dboard
    query = cvuser ? query.where({cvuser_id: cvuser.not_nil!.id}) : query.with_cvuser

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
    if cu_privi < 0 || (cu_privi < 3 && dboard.id < 0)
      return halt! 403, "Quyền hạn không đủ"
    end

    dtopic = Dtopic.new({cvuser: _cvuser, dboard: dboard})

    dtopic.set_title(params["title"])
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
    if cu_privi < 0 || (cu_privi < 3 && dboard.id < 0)
      return halt! 403, "Quyền hạn không đủ"
    end

    dtopic = Dtopic.load!(params["dtopic"].to_i64)
    if cu_privi < 0 || _cvuser.id != dtopic.cvuser_id
      return halt! 403, "Quyền hạn không đủ"
    end

    dtopic.set_utime(Time.utc.to_unix)

    dtopic.save!

    json_view do |jb|
      jb.object {
        jb.field "dtopic" { DtopicView.render(jb, dtopic, dboard) }
      }
    end
  end
end
