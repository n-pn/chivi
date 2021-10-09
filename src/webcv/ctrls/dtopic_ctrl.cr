require "./base_ctrl"

class CV::DtopicCtrl < CV::BaseCtrl
  def index
    limit = params.fetch_int("take", min: 1, max: 24)
    pgidx = params.fetch_int("page", min: 1)
    skips = (pgidx - 1) * limit

    query = Dtopic.query.order_by(_sort: :desc)

    if dboard_id = params["dboard"]?
      dboard = Dboard.load!(dboard_id.to_i64)
      query.where({dboard_id: dboard.id})
    else
      query.with_dboard
    end

    if user_name = params["cvuser"]?
      cvuser = Cvuser.load!(user_name)
      query.where({cvuser_id: cvuser.id})
    else
      query.with_cvuser
    end

    total = query.dup.limit(limit * 3 + skips).offset(0).count

    cache_rule :public, 30, 120

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

              DtopicView.render(jb, dtopic, dboard, cvuser)
            end
          }
        }
      }
    end
  end

  def show
    dtopic = Dtopic.load!(params["dtopic"].to_i64)
    dtopic.update!({views: dtopic.view + 1})
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

    utime = Time.utc.to_unix
    dtpost = Dtpost.new({cvuser: _cvuser, dt_id: 0, utime: utime})
    dtopic = Dtopic.new({cvuser: _cu_user, cvboard: cvboard, dt_id: 0, utime: utime})

    dtopic.set_title(params["title"])
    dtpost.set_input(params["tbody"], params["itype"]? || "md")

    dtopic.pdesc = dtpost.odesc
    dtopic.posts = 1
    dtopic._sort = utime // 60

    dtopic.save!
    dtpost.dtopic = dtopic
    dtpost.save!

    json_view do |jb|
      jb.object {
        jb.field "dtopic" { DtopicView.render(jb, dtopic, dboard) }
        jb.field "dtpost" { DtpostView.render(jb, dtpost, _cvuser) }
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

    dtpost = Dtpost.find!({dtopic_id: dtopic.id, dt_id: 0})

    utime = Time.utc.to_unix
    dtopic.utime = utime
    dtpost.utime = utime
    dtopic.update_sort(utime)

    dtopic.set_title(params["title"])
    dtpost.set_input(params["tbody"], params["itype"]? || "md")
    dtopic.pdesc = dtpost.odesc

    dtpost.edits += 1
    dtopic.save!
    dtpost.save!

    json_view do |jb|
      jb.object {
        jb.field "dtopic" { DtopicView.render(jb, dtopic, dboard) }
        jb.field "dtpost" { DtpostView.render(jb, dtpost, _cvuser) }
      }
    end
  end
end
