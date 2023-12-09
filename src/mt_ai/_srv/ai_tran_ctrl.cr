require "./_mt_ctrl_base"

class MT::AiTranCtrl < AC::Base
  base "/_ai"

  ALGOS = {"mtl_0", "mtl_1", "mtl_2", "mtl_3"}

  @[AC::Route::GET("/qtran")]
  def qtran_file(fpath : String, pdict : String = "combine", _algo : String = "mtl_1", force : Bool = false)
    start = Time.monotonic
    force = force && _privi >= 0

    zdata = File.read_lines("var/texts/#{fpath}.raw.txt", chomp: true)
    mdata = MCache.find_all!(zdata, (ALGOS.index(_algo) || 1).to_i16)

    ai_mt = AiCore.new(pdict)

    lines = mdata.map { |mline| ai_mt.translate!(mline.con) }
    tspan = (Time.monotonic - start).total_milliseconds.round(2)

    cache_control 3.seconds
    mtime = Time.utc.to_unix

    json = {
      lines: lines,
      ztree: mdata.map(&.con.to_s),
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
