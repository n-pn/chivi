# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"

class MT::QtTranCtrl < AC::Base
  base "/_ai"

  TEXT_DIR = "var/wnapp/chtext"

  private def gen_fpath(zpath : String, ftype : String)
    case ftype
    when "nctext" then "#{TEXT_DIR}/#{zpath}.txt"
    else               raise "unsupported!"
    end
  end

  @[AC::Route::GET("/hviet")]
  def hviet_file(zpath : String, ftype : String = "nctext", w_raw : Bool = false)
    start = Time.monotonic

    fpath = gen_fpath(zpath, ftype)
    ztext = File.read_lines(fpath, chomp: true)

    mcore = QtCore.hv_word
    hviet = ztext.map { |line| HvietToVarr.new(mcore.tokenize(line)) }

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    mtime = Time.utc.to_unix

    cache_control 7.days
    add_etag mtime.to_s

    ztext.clear unless w_raw
    render json: {hviet: hviet, ztext: ztext, tspan: tspan, mtime: mtime}
  rescue ex
    Log.error(exception: ex) { ex.message }
    render json: {hviet: [] of String, error: ex.message}
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
    render json: {hviet: [] of String, error: ex.message}
  end
end
