require "./base_ctrl"

class CV::MarkCtrl < CV::BaseCtrl
  def show : Nil
    if _cv_user.privi < 0
      return render_json({bmark: "default"})
    end

    cvbook = Cvbook.load!(params["bname"])
    ubmemo = Ubmemo.find!({cvuser_id: _cv_user.id, cvbook_id: cvbook.id})
    render_json({bmark: ubmemo.status_s})
  rescue
    render_json({bmark: "default"})
  end

  def update
    return halt!(404, "Người dùng chưa đăng nhập!") if _cv_user.privi < 0

    cvbook = Cvbook.load!(params["bname"])
    status = Ubmemo.status(params.fetch_str("bmark", "default"))

    Ubmemo.upsert!(_cv_user, cvbook, &.status = status)
    render_json({bmark: status})
  end

  def history
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 15, max: 30)

    query = Ubmemo.query.limit(take).offset(skip).order_by(bumped: :desc)
    query.where("cvuser_id = #{_cv_user.id}")

    render_json do |res|
      JSON.build(res) do |json|
        json.array do
          take.times do
            query.with_cvbook.each do |ubmemo|
              json.object {
                json.field "bname", ubmemo.cvbook.bname
                json.field "bslug", ubmemo.cvbook.bslug

                # json.field "atime", ubmemo.bumped

                json.field "sname", ubmemo.sname
                json.field "chidx", ubmemo.chidx

                json.field "title", ubmemo.ch_title
                json.field "uslug", ubmemo.ch_uslug
              }
            end
          end
        end
      end
    end
  rescue err
    puts err
  end
end
