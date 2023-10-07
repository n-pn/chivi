require "./_mt_ctrl_base"

class MT::AiTranCtrl < AC::Base
  base "/_ai"

  @[AC::Route::GET("/qtran")]
  def qtran_file(fpath : String, pdict : String = "combine", _algo : String = "avail", force : Bool = false)
    start = Time.monotonic
    force = force && _privi >= 0

    cdata = RD::Chpart.new(fpath)
    mdata, _algo = cdata.read_con(_algo, force: force)

    ai_mt = AiCore.new(pdict)

    lines = mdata.map { |line| ai_mt.tl_from_con_data(line) }
    tspan = (Time.monotonic - start).total_milliseconds.round(2)

    cache_control 3.seconds
    mtime = Time.utc.to_unix

    json = {
      lines: lines,
      tspan: tspan,
      dsize: ai_mt.dict.dsize,
      mtime: mtime,
      m_alg: _algo,
    }

    render json: json
  rescue ex
    status = ex.message == "404" ? 404 : 500

    if status == 500
      Log.error(exception: ex) { [fpath, pdict] }
    end

    render status, json: {lines: [] of String, error: ex.message}
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
