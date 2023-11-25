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

  @[AC::Route::GET("/wnstems/:sname/:sn_id")]
  def show(sname : String, sn_id : Int32, crawl : Int32 = 0, regen : Bool = false)
    wstem = get_wstem(sname, sn_id)
    wstem.update!(crawl, regen) if crawl > 0 || regen
    rmemo = Rdmemo.load!(vu_id: self._vu_id, sname: "wn#{sname}", sn_id: sn_id.to_s)

    render json: {
      wstem: wstem,
      crepo: wstem.crepo,
      rmemo: rmemo,
    }
  end
end
