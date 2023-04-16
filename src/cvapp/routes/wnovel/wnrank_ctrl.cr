require "../_ctrl_base"

class CV::WnrankCtrl < CV::BaseCtrl
  base "/_db/ranks"

  @[AC::Route::GET("/brief")]
  def brief
    book_query = Wninfo.query.where("shield < 2").limit(6)

    render json: {
      recent: WnovelView.as_list(book_query.dup.sort_by("access")),
      update: WnovelView.as_list(book_query.dup.sort_by("update")),
      weight: WnovelView.as_list(book_query.dup.sort_by("weight")),
    }
  end
end
