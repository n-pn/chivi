require "../_ctrl_base"

class CV::BlabelCtrl < CV::BaseCtrl
  base "/_db/blbls"

  @[AC::Route::GET("/")]
  def index(type : Blabel::Type)
    render json: Blabel.fetch_all(type)
  end

  @[AC::Route::GET("/front")]
  def front
    response.headers["Cache-Control"] = "public, s-maxage=3600, immutable"

    render json: {
      seeds: Blabel.fetch_all(:seed),
      origs: Blabel.fetch_all(:orig),
    }
  end
end
