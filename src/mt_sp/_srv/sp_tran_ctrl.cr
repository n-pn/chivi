require "../../mt_ai/core/qt_core"
require "./_sp_ctrl_base"
require "../util/*"

# require "../../_data/logger/qtran_xlog"

class SP::TranCtrl < AC::Base
  base "/_sp"

  @[AC::Route::GET("/hname")]
  def hname(input : String)
    render text: MT::QtCore.tl_hvname(input)
  rescue ex
    Log.error(exception: ex) { ex.message }
    render text: ex.message
  end

  TEXT_DIR = "var/wnapp/chtext"
  TRAN_DIR = "var/wnapp/chtran"

  private def gen_fpath(zpath : String, ftype : String)
    case ftype
    when "nctext" then "#{TEXT_DIR}/#{zpath}.txt"
    else               raise "unsupported!"
    end
  end

  @[AC::Route::GET("/hviet")]
  def hviet_file(zpath : String, ftype = "nctext")
    start = Time.monotonic
    hviet = MT::QtCore.hv_word.translate_file(gen_fpath(zpath, ftype))

    mtime = Time.utc.to_unix

    cache_control 7.days
    add_etag mtime.to_s

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    render json: {lines: hviet, mtime: mtime, tspan: tspan}
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, json: {hviet: [] of String, error: ex.message}
  end

  @[AC::Route::POST("/hviet")]
  def hviet_text
    start = Time.monotonic

    mcore = MT::QtCore.hv_word
    hviet = [] of String

    _read_body.each_line do |line|
      hviet << mcore.tokenize(line).to_txt
    end

    tspan = (Time.monotonic - start).total_milliseconds.round(2)

    render json: {lines: hviet, tspan: tspan}
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, json: {lines: [] of String, error: ex.message}
  end

  @[AC::Route::GET("/btran")]
  def btran_file(zpath : String, ftype : String = "nctext", force : Bool = true)
    start = Time.monotonic

    bv_path = "#{TRAN_DIR}/#{zpath}.bzv.txt"

    if stat = File.info?(bv_path)
      lines = File.read_lines(bv_path)
      mtime = stat.modification_time.to_unix
      status = 200
    elsif force && _privi >= 0
      input = File.read_lines("#{TEXT_DIR}/#{zpath}.txt", chomp: true)
      lines = Btran.free_translate(input, tl: "vi")
      mtime = Time.utc.to_unix
      status = 201
      spawn do
        Dir.mkdir_p(File.dirname(bv_path))
        File.write(bv_path, lines.join('\n'))
      end
    else
      lines = [] of String
      mtime = 0_i64
      error = "n/a"
      status = 404
    end

    unless mtime == 0
      cache_control 7.days
      add_etag mtime.to_s
    end

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    render status, json: {lines: lines, tspan: tspan, mtime: mtime, error: error}
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, json: {lines: [] of String, error: ex.message}
  end

  @[AC::Route::POST("/btran")]
  def btran_text(sl : String = "zh", tl : String = "vi", no_cap : Bool = false)
    start = Time.monotonic

    lines = Btran.translate(_read_body.lines, sl: sl, tl: tl, no_cap: no_cap)
    tspan = (Time.monotonic - start).total_milliseconds.round(2)

    cache_control 7.days, "private"

    render json: {lines: lines, tspan: tspan}
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, json: {lines: [] of String, error: ex.message}
  end

  @[AC::Route::POST("/deepl")]
  def deepl_text(sl : String = "zh", tl : String = "en", no_cap : Bool = false)
    output = Deepl.translate(_read_body.lines, source: sl, target: tl, no_cap: no_cap)
    response.content_type = "text/plain; charset=utf-8"
    render text: output.join('\n', &.[1])
  end
end
