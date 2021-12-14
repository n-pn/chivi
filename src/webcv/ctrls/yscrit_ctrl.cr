require "./base_ctrl"

class CV::YscritCtrl < CV::BaseCtrl
  def index
    page = params.fetch_int("page", min: 1)
    take = params.fetch_int("take", min: 1, max: 20)
    skip = (page - 1) &* take

    query = Yscrit.sort_by(params["sort"]?)
      .filter_ysuser(params["user"]?.try(&.to_i64?))
      .with_ysuser

    if book_id = params["book"]?.try(&.to_i64?)
      query.filter_nvinfo(book_id)

      total = query.dup.count
      crits = query.limit(take).offset(skip).to_a

      if crits.size > 0
        nvinfo = Nvinfo.load!(book_id)
        crits.each { |x| x.nvinfo = nvinfo }
      end
    else
      total = query.dup.limit((page + 2) * take).count
      crits = query.limit(take).offset(skip).to_a

      if crits.size > 0
        nvinfos = Nvinfo.query.with_author.where("id = ANY(?)", crits.map(&.nvinfo_id))
        bookmap = nvinfos.map { |x| {x.id, x} }.to_h

        crits.each { |x| x.nvinfo = bookmap[x.nvinfo_id] }
      end
    end

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "pgidx", page
          jb.field "pgmax", pgmax(total, take)

          jb.field "crits" do
            jb.array do
              crits.each { |crit| render_crit(jb, crit) }
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
    crit_id = UkeyUtil.decode32(params["crit"])
    unless yscrit = Yscrit.find({id: crit_id})
      return halt! 404, "Đánh giá không tồn tại"
    end

    render_json do |res|
      JSON.build(res) do |jb|
        render_crit(jb, yscrit)
      end
    end
  end

  def replies
    crit_id = UkeyUtil.decode32(params["crit"])
    unless yscrit = Yscrit.find({id: crit_id})
      return halt! 404, "Đánh giá không tồn tại"
    end

    render_json do |res|
      JSON.build(res) do |jb|
        jb.array {
          query = Ysrepl.query.where("yscrit_id = ?", yscrit.id)

          query.with_ysuser.each { |repl|
            jb.object {
              jb.field "uname", repl.ysuser.vname
              jb.field "uslug", repl.ysuser.id
              jb.field "vhtml", repl.vhtml

              jb.field "mftime", repl.created_at.to_unix
              jb.field "like_count", repl.like_count
            }
          }
        }
      end
    end
  end

  private def render_crit(jb : JSON::Builder, crit : Yscrit)
    jb.object do
      jb.field "id", UkeyUtil.encode32(crit.id)

      jb.field "bid", crit.nvinfo.id
      jb.field "bname", crit.nvinfo.vname
      jb.field "bslug", crit.nvinfo.bslug
      jb.field "bhash", crit.nvinfo.bhash

      jb.field "author", crit.nvinfo.author.vname
      jb.field "bgenre", crit.nvinfo.genres.first? || "Loại khác"

      jb.field "uname", crit.ysuser.vname
      jb.field "uslug", crit.ysuser.id

      jb.field "stars", crit.stars

      jb.field "vhtml", crit.vhtml

      jb.field "like_count", crit.like_count
      jb.field "repl_count", crit.repl_count

      jb.field "mftime", crit.mftime
    end
  end
end
