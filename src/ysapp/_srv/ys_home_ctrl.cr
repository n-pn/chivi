require "./_ys_ctrl_base"
require "./views/*"

class YS::HomeCtrl < AC::Base
  base "/_ys"

  @[AC::Route::GET("/front")]
  def index
    crits = Yscrit.query.order_by(utime: :desc).offset(0).limit(2)
    lists = Yslist.query.where("book_count > 0").order_by(utime: :desc).offset(0).limit(3)

    books = Wninfo.preload(crits.map(&.nvinfo_id))

    u_ids = crits.map(&.ysuser_id).concat(lists.map(&.ysuser_id))
    users = Ysuser.preload(u_ids)

    render json: {
      vbooks: BookView.as_hash(books),
      ycrits: YscritView.as_list(crits),
      ylists: ListView.as_list(lists),
      yusers: UserView.as_hash(users),
    }
  end
end
