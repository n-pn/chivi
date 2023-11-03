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
        io << mcore.to_mtl(line.gsub('　', "")) << '\n'
      end
    end

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    mtime = Time.utc.to_unix

    # cache_control 7.days
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
    mcore = QtCore.hv_word

    hviet = String.build do |io|
      _read_body.each_line { |line| io << mcore.to_mtl(line) << '\n' }
    end

    render text: hviet
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, text: ex.message
  end
end
