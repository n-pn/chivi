require "./_ctrl_base"

class RD::ChrepoCtrl < AC::Base
  base "/_rd/chrepos"

  @[AC::Route::GET("/:sname/:sn_id")]
  def show(sname : String, sn_id : String)
    crepo = Chrepo.load!("#{sname}/#{sn_id}")
    xstem = get_xstem(crepo)

    rmemo = Rdmemo.load!(vu_id: self._vu_id, sname: sname, sn_id: sn_id)

    render json: {
      xstem: xstem,
      crepo: crepo,
      rmemo: rmemo,
    }
  end
end
