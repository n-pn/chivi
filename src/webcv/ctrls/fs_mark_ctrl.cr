require "./base_ctrl"

class CV::FsMarkCtrl < CV::BaseCtrl
  def show : Nil
    if _cv_user.privi < 0
      return render_json({bmark: "default"})
    end

    cvbook = Cvbook.load!(params["bname"])
    ubmark = Ubmark.find!({cvuser_id: _cv_user.id, cvbook_id: cvbook.id})
    render_json({bmark: ubmark.label})
  rescue
    render_json({bmark: "default"})
  end

  def update
    return halt!(404, "Người dùng chưa đăng nhập!") if _cv_user.privi < 0
    cvbook = Cvbook.load!(params["bname"])

    bmark = Ubmark.bmark(params.fetch_str("bmark"))
    Ubmark.upsert!(_cv_user, cvbook, bmark)
    render_json({bmark: bmark})
  end

  def history
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 15, max: 30)

    query = Ubview.query.limit(take).offset(skip).order_by(bumped: :desc)
    query.where("cvuser_id = #{_cv_user.id}")

    render_json do |res|
      JSON.build(res) do |json|
        json.array do
          take.times do
            query.with_cvbook.each do |ubview|
              json.object {
                json.field "bname", ubview.cvbook.bname
                json.field "bslug", ubview.cvbook.bslug

                # json.field "atime", ubview.bumped

                json.field "sname", ubview.sname
                json.field "chidx", ubview.chidx

                json.field "title", ubview.ch_title
                json.field "uslug", ubview.ch_uslug
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
