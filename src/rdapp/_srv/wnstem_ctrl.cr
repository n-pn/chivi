require "./_ctrl_base"

class RD::WnstemCtrl < AC::Base
  base "/_rd"

  @[AC::Route::GET("/bstems/:wn_id")]
  def for_wn(wn_id : Int32)
    render json: {
      wstems: ChstemView.wstems_by_wn(wn_id),
      rstems: ChstemView.rstems_by_wn(wn_id),
      ustems: ChstemView.ustems_by_wn(wn_id),
    }
  end
end
