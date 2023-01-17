require "./_ys_ctrl_base"
require "./views/*"

class YS::HomeCtrl < AC::Base
  base "/_ys"

  @[AC::Route::GET("/")]
  def index
    crits = Yscrit.query.order_by(utime: :desc).offset(0)
    lists = Yslist.query.where("book_count > 0").order_by(utime: :desc).offset(0)

    books = CvBook.query.where { id.in? crits.map(&.nvinfo_id) }

    render json: {
      vbooks: BookView.as_hash(books),
      ycrits: CritView.map(crits.limit(2)),
      ylists: ListView.map(lists.limit(3)),
    }
  end
end
