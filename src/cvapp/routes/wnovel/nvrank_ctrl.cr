require "../_ctrl_base"

class CV::NvrankCtrl < CV::BaseCtrl
  base "/_db/ranks"

  @[AC::Route::GET("/brief")]
  def brief
    book_query = Nvinfo.query.where("shield < 2").limit(6)

    render json: {
      recent: WnovelView.map(book_query.dup.sort_by("access")),
      update: WnovelView.map(book_query.dup.sort_by("update")),
      weight: WnovelView.map(book_query.dup.sort_by("weight")),
    }
  end
end
