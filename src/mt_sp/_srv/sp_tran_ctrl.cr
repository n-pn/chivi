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

  @[AC::Route::GET("/hviet")]
  def hviet_file(fpath : String)
    start = Time.monotonic
    mcore = MT::QtCore.hv_word

    ztext = ChapData.new(fpath).read_raw
    hviet = ztext.map { |line| mcore.tokenize(line).to_txt }

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
  def btran_file(fpath : String, force : Bool = true)
    start = Time.monotonic
    cdata = ChapData.new(fpath)

    tl_path = cdata.vtl_file_path("bzv.txt")

    if stat = File.info?(tl_path)
      lines = File.read_lines(tl_path)
      mtime = stat.modification_time.to_unix
      status = 200
    elsif force && _privi >= 0
      lines = Btran.free_translate(cdata.read_raw, tl: "vi")
      mtime = Time.utc.to_unix
      status = 201
      spawn do
        Dir.mkdir_p(File.dirname(tl_path))
        File.write(tl_path, lines.join('\n'))
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

  @[AC::Route::POST("/c_gpt")]
  def c_gpt_text
    url = "http://51.79.230.157:9090/"
    body = {test_key: _read_body}.to_json
    headers = HTTP::Headers{"Content-Type" => "application/json"}

    HTTP::Client.post(url, headers: headers, body: body) do |res|
      raise res.body unless res.status.success?

      json = NamedTuple(result: String).from_json(res.body_io.gets_to_end)
      render text: json[:result]
    end
  end
end
