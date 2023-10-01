# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"

class MT::QtTranCtrl < AC::Base
  base "/_ai"

  TEXT_DIR = "var/wnapp/chtext"

  @[AC::Route::GET("/hviet")]
  def hviet_file(fpath : String)
    start = Time.monotonic

    ztext = RD::Chdata.read_raw(fpath)

    mcore = QtCore.hv_word
    hviet = ztext.map { |line| HvietToVarr.new(mcore.tokenize(line)) }

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    mtime = Time.utc.to_unix

    cache_control 7.days
    add_etag mtime.to_s

    render json: {hviet: hviet, tspan: tspan, mtime: mtime}
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, json: {hviet: [] of String, error: ex.message}
  end

  @[AC::Route::POST("/hviet")]
  def hviet_text
    start = Time.monotonic
    mcore = QtCore.hv_word

    hviet = [] of HvietToVarr
    _read_body.each_line { |line| hviet << HvietToVarr.new(mcore.tokenize(line)) }

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    mtime = Time.utc.to_unix

    render json: {hviet: hviet, tspan: tspan, mtime: mtime}
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, json: {hviet: [] of String, error: ex.message}
  end
end
