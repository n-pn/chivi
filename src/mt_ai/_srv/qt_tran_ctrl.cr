# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"

class MT::QtTranCtrl < AC::Base
  base "/_ai"

  TEXT_DIR = "var/wnapp/chtext"

  @[AC::Route::GET("/qt/hviet")]
  def hviet_file(fpath : String)
    start = Time.monotonic
    mcore = QtCore.hv_word

    hviet = String.build do |io|
      RD::Chpart.read_raw(fpath) do |line|
        io << mcore.to_mtl(line) << '\n'
      end
    end

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    mtime = Time.utc.to_unix

    cache_control 7.days
    add_etag mtime.to_s

    response.headers["X-TSPAN"] = tspan.to_s
    response.headers["X-MTIME"] = mtime.to_s

    render text: hviet
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, text: ex.message
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
