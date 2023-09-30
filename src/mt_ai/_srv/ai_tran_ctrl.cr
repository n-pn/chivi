require "./_mt_ctrl_base"

class MT::AiTranCtrl < AC::Base
  base "/_ai"

  @[AC::Route::GET("/qtran")]
  def qtran_file(fpath : String, pdict : String = "combine", _algo : String = "avail", force : Bool = false)
    start = Time.monotonic
    force = force && _privi >= 0

    cdata = ChapData.new(fpath)
    mdata, _algo = cdata.read_con(_algo, force: force)

    ai_mt = AiCore.new(pdict)

    lines = mdata.map { |line| ai_mt.tl_from_con_data(line) }
    tspan = (Time.monotonic - start).total_milliseconds.round(2)

    cache_control 3.seconds
    mtime = Time.utc.to_unix

    json = {lines: lines, mtime: mtime, tspan: tspan, _algo: _algo}

    render json: json
  rescue ex
    Log.error(exception: ex) { [fpath, pdict] }
    render 500, json: {lines: [] of String, error: ex.message}
  end

  @[AC::Route::POST("/reload")]
  def reload(pdict : String = "combine")
    start = Time.monotonic
    ai_mt = AiCore.new(pdict)

    input = _read_body.lines(chomp: true)
    trees = input.map { |line| ai_mt.tl_from_con_data(line) }

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    json = {lines: trees, tspan: tspan}

    render json: json
  rescue ex
    Log.error(exception: ex) { input }
    render 455, ex.message
  end
end
