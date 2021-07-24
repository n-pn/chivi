require "./base_ctrl"

class CV::CritCtrl < CV::BaseCtrl
  def index
    page = params.fetch_int("page", min: 1)
    take = params.fetch_int("take", min: 10, max: 20)
    skip = (page - 1) &* take

    query = Yscrit.sort_by(params["sort"]?)
    query.filter_cvbook(params["book"]?.try(&.to_i?))

    total = query.dup.limit((page + 2) * take).count
    query = query.limit(take).offset(skip).with_cvbook.with_ysuser

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "pgidx", page
          jb.field "pgmax", pgmax(total, take)

          jb.field "crits" do
            jb.array do
              query.each { |crit| render_crit(jb, crit) }
            end
          end
        end
      end
    end
  rescue err
    puts err.inspect_with_backtrace.colorize.red
    halt! 500, err.message
  end

  private def render_crit(jb : JSON::Builder, crit : Yscrit)
    jb.object do
      jb.field "id", crit.id

      jb.field "book_name", crit.cvbook.bname
      jb.field "book_slug", crit.cvbook.bslug

      jb.field "user_name", crit.ysuser.vname
      jb.field "user_slug", crit.ysuser.id

      jb.field "stars", crit.stars
      jb.field "vhtml", crit.vhtml

      jb.field "like_count", crit.like_count
      jb.field "repl_count", crit.repl_count

      jb.field "mftime", crit.mftime
    end
  end
end
