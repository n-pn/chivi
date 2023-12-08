require "./_mt_ctrl_base"

class MT::AiTranCtrl < AC::Base
  base "/_ai"

  @[AC::Route::GET("/qtran")]
  def qtran_file(fpath : String, pdict : String = "combine", _algo : String = "avail", force : Bool = false)
    start = Time.monotonic
    force = force && _privi >= 0

    cdata = RD::Chpart.new(fpath)
    ztree, _algo = cdata.read_con(_algo, force: force)

    ai_mt = AiCore.new(pdict)

    lines = ztree.map { |line| ai_mt.translate!(RawCon.from_text(line)) }
    tspan = (Time.monotonic - start).total_milliseconds.round(2)

    cache_control 3.seconds
    mtime = Time.utc.to_unix

    json = {
      lines: lines,
      ztree: ztree,
      tspan: tspan,
      dsize: ai_mt.dict.dsize,
      mtime: mtime,
      m_alg: _algo,
    }

    render json: json
  rescue ex
    status = ex.message == "404" ? 404 : 500
    Log.error(exception: ex) { [fpath, pdict] }
    render status, json: {lines: [] of String, error: ex.message}
  end

  @[AC::Route::POST("/reload")]
  def reload(pdict : String = "combine")
    start = Time.monotonic
    ai_mt = AiCore.new(pdict)

    input = _read_body.lines(chomp: true)
    trees = input.map { |line| ai_mt.translate!(RawCon.from_text(line)) }

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    json = {lines: trees, tspan: tspan}

    render json: json
  rescue ex
    Log.error(exception: ex) { input }
    render 455, ex.message
  end

  @[AC::Route::POST("/debug")]
  def debug(pdict : String = "combine", m_alg = "mtl_1")
    start = Time.monotonic

    input = _read_body.strip
    hlink = "#{CV_ENV.lp_host}/mtl_text/#{m_alg}"
    ztree = HTTP::Client.post(hlink, body: input, &.body_io.gets_to_end).lines

    ai_mt = AiCore.new(pdict)
    vdata = ztree.map { |line| ai_mt.translate!(RawCon.from_text(line)) }

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    json = {lines: vdata, ztree: ztree, tspan: tspan}

    render json: json
  rescue ex
    Log.error(exception: ex) { input }
    render 455, ex.message
  end
end
