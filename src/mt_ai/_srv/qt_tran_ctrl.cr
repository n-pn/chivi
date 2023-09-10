# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"

class MT::QtTranCtrl < AC::Base
  base "/_ai/qt"

  @[AC::Route::GET("/hviet")]
  def hviet(zpath : String, force : Bool = false)
    start = Time.monotonic

    lines = MtTranUtil.read_txt(zpath)
    cdata = lines.map { |line| MT::QtCore.hv_word.tokenize(line) }

    tspan = (Time.monotonic - start).total_milliseconds.to_i
    render json: {cdata: cdata, tspan: tspan}
  rescue ex
    Log.error(exception: ex) { ex.message }
    render json: {cdata: [] of String, tspan: 0, eror: ex.message}
  end

  @[AC::Route::GET("/btran")]
  def btran(zpath : String, force : Bool = false)
    start = Time.monotonic
    btran = MtTranUtil.get_wntext_btran_data(zpath, force: force)

    tspan = (Time.monotonic - start).total_milliseconds.to_i
    render json: {cdata: btran, tspan: tspan}
  rescue ex
    render json: {cdata: [] of String, tspan: 0, eror: ex.message}
  end
end
