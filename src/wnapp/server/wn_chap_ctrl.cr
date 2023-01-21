require "./_wn_ctrl_base"

class WN::ChapCtrl < AC::Base
  base "/_wn/chaps/:sname/:s_bid"

  @[AC::Route::GET("/")]
  def index(sname : String, s_bid : Int32, pg pg_no : Int32 = 1)
    wn_seed = get_wn_seed(sname, s_bid)
    # TODO: restrict user access
    render json: wn_seed.vi_chaps.all(pg_no)
  end
end
