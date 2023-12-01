require "./_ctrl_base"

class RD::TsrepoCtrl < AC::Base
  base "/_rd/tsrepos"

  @[AC::Route::GET("/:sname/:sn_id")]
  def show(sname : String, sn_id : Int32)
    crepo = Tsrepo.load!("#{sname}/#{sn_id}")
    crepo.fix_pdict! if crepo.pdict.empty?

    rmemo = Rdmemo.load!(vu_id: self._vu_id, sname: sname, sn_id: sn_id)
    xstem = get_xstem(crepo)

    render json: {
      xstem: xstem,
      crepo: crepo,
      rmemo: rmemo,
    }
  end
end
