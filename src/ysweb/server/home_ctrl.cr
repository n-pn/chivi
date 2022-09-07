require "./views/list_view"
require "./views/crit_view"
require "./_ctrl_base"

module YS
  class HomeCtrl < BaseCtrl
    base "/_ys"

    @[AC::Route::GET("/")]
    def index
      crits = CV::Yscrit.query.order_by(utime: :desc).offset(0)
      lists = CV::Yslist.query.where("book_count > 0").order_by(utime: :desc).offset(0)

      render json: {
        ycrits: CritView.map(crits.limit(2)),
        ylists: ListView.map(lists.limit(3)),
      }
    end
  end
end
