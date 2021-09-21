require "./base_ctrl"

class CV::MemoCtrl < CV::BaseCtrl
  def history
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 15, max: 30)

    query = Ubmemo.query.where("cvuser_id = #{_cv_user.id}")
    query = query.limit(take).offset(skip).order_by(bumped: :desc)

    render_json do |res|
      JSON.build(res) do |jb|
        jb.array do
          take.times do
            query.with_cvbook.each do |ubmemo|
              jb.object {
                jb.field "bname", ubmemo.cvbook.bname
                jb.field "bslug", ubmemo.cvbook.bslug

                jb.field "status", ubmemo.status_s
                jb.field "locked", ubmemo.locked

                jb.field "sname", ubmemo.lr_sname
                jb.field "chidx", ubmemo.lr_chidx

                jb.field "title", ubmemo.lc_title
                jb.field "uslug", ubmemo.lc_uslug
              }
            end
          end
        end
      end
    end
  rescue err
    puts err
  end

  def library
  end

  def update_history
  end

  def update_library
    raise "Người dùng chưa đăng nhập!" if _cv_user.privi < 0

    cvbook_id = params["book_id"].to_i64
    status = Ubmemo.status(params.fetch_str("status", "default"))

    Ubmemo.upsert!(_cv_user.id, cvbook_id, &.status = status)
    render_json({status: status})
  rescue err
    halt!(500, err.message)
  end

  def show : Nil
    return render_json({status: "default"}) if _cv_user.privi < 0

    cvbook = Cvbook.load!(params["bname"])
    ubmemo = Ubmemo.find!({cvuser_id: _cv_user.id, cvbook_id: cvbook.id})
    render_json({bmark: ubmemo.status_s})
  rescue
    render_json({bmark: "default"})
  end
end
