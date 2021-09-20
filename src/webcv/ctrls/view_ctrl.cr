require "./base_ctrl"

class CV::ViewCtrl < CV::BaseCtrl
  def index
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 15, max: 30)

    query = Ubmemo.query.where("cvuser_id = #{_cv_user.id}")
    query = query.limit(take).offset(skip).order_by(bumped: :desc)

    render_json do |res|
      JSON.build(res) do |json|
        json.array do
          query.with_cvbook.each do |ubmemo|
            json.object {
              json.field "bname", ubmemo.cvbook.bname
              json.field "bslug", ubmemo.cvbook.bslug

              json.field "sname", ubmemo.lr_sname
              json.field "chidx", ubmemo.lr_chidx

              json.field "title", ubmemo.lc_title
              json.field "uslug", ubmemo.lc_uslug

              json.field "locked", ubmemo.locked
            }
          end
        end
      end
    end
  rescue err
    puts err
  end
end
