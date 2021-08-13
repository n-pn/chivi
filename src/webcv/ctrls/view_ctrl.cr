require "./base_ctrl"

class CV::ViewCtrl < CV::BaseCtrl
  def index
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 15, max: 30)

    query = Ubview.query.where("cvuser_id = #{_cv_user.id}")
    query = query.limit(take).offset(skip).order_by(bumped: :desc)

    render_json do |res|
      JSON.build(res) do |json|
        json.array do
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
  rescue err
    puts err
  end
end
