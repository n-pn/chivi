require "./base_ctrl"

class CV::CritCtrl < CV::BaseCtrl
  def index
    page = params.fetch_int("page", min: 1)
    take = params.fetch_int("take", min: 10, max: 20)
    skip = (page - 1) &* take

    query = Yscrit.sort_by(params["sort"]?)

    book = params["book"]?.try(&.to_i?)

    query.filter_cvbook(book)
    query.filter_ysuser(params["user"]?.try(&.to_i?))

    total = book ? query.dup.count : query.dup.limit((page + 2) * take).count
    query = query.limit(take).offset(skip).with_cvbook(&.with_author).with_ysuser

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

  def show
    crit_id = CoreUtils.decode32(params["crit"])
    unless yscrit = Yscrit.find({id: crit_id})
      return halt! 404, "Đánh giá không tồn tại"
    end

    render_json do |res|
      JSON.build(res) do |jb|
        render_crit(jb, yscrit, mtl: true)
      end
    end
  end

  private def render_crit(jb : JSON::Builder, crit : Yscrit, mtl = false)
    jb.object do
      jb.field "id", CoreUtils.encode32(crit.id)

      jb.field "bid", crit.cvbook.id
      jb.field "bname", crit.cvbook.bname
      jb.field "bslug", crit.cvbook.bslug
      jb.field "genre", crit.cvbook.bhash

      jb.field "author", crit.cvbook.author.vname
      jb.field "bgenre", crit.cvbook.bgenres.first? || "Loại khác"

      jb.field "uname", crit.ysuser.vname
      jb.field "uslug", crit.ysuser.id

      jb.field "stars", crit.stars

      jb.field "vhtml", mtl ? crit.cvdata(mode: cu_tlmode) : crit.vhtml

      jb.field "like_count", crit.like_count
      jb.field "repl_count", crit.repl_count

      jb.field "mftime", crit.mftime
    end
  end
end
