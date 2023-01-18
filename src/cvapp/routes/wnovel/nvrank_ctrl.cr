require "../_ctrl_base"

class CV::NvrankCtrl < CV::BaseCtrl
  base "/api/ranks"

  @[AC::Route::GET("/brief")]
  def brief
    book_query = Nvinfo.query.where("shield < 2").limit(6).offset(0)

    render json: {
      recent: NvinfoView.map(book_query.dup.sort_by("access")),
      update: NvinfoView.map(book_query.dup.sort_by("update")),
      weight: NvinfoView.map(book_query.dup.sort_by("weight")),
    }
  end
end