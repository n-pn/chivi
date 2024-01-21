require "./_mt_ctrl_base"
require "../data/m_cache"

class MT::AiTranCtrl < AC::Base
  base "/_ai"

  ALGOS = {"mtl_0", "mtl_1", "mtl_2", "mtl_3"}

  @[AC::Route::GET("/qtran")]
  def qfile(fpath : String, pdict : String = "combine", _algo : String = "mtl_1",
            ch_rm : UInt32 = 1_u32, debug : Bool = false)
    ztext = File.read_lines("var/texts/#{fpath}.raw.txt", chomp: true)
    json = do_qtran(ztext, pdict, _algo, ch_rm: ch_rm, debug: debug)

    cache_control 3.seconds
    render json: json
  rescue ex
    status = ex.message == "404" ? 404 : 500
    Log.error(exception: ex) { [fpath, pdict] }
    render status, json: {lines: [] of String, error: ex.message}
  end

  @[AC::Route::POST("/qtran")]
  def qtext(pdict : String = "combine", _algo : String = "mtl_1",
            ch_rm : UInt32 = 1_u32, debug : Bool = false)
    ztext = self._read_body.lines(chomp: true)
    json = do_qtran(ztext, pdict, _algo, ch_rm: ch_rm, debug: debug)
    render json: json
  rescue ex
    Log.error(exception: ex) { ztext }
    render 455, ex.message
  end

  private def do_qtran(input : Array(String), pdict : String, m_alg : String, ch_rm : UInt32, debug = false)
    start = Time.monotonic
    heads = [] of MtNode | Nil

    ch_rm.times do |index|
      title, split = TlChap.split(input[index])
      input[index] = title
      heads << split
    end

    ai_mt = AiCore.new(pdict)
    zdata = MCache.find_con!(input, ver: m_alg[-1].to_i16)

    vdata = zdata.map_with_index do |line, l_id|
      ai_mt.translate!(line, prfx: heads[l_id]?)
    end

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    ztree = debug ? zdata.map(&.to_s) : [] of String

    {lines: vdata, ztree: ztree, tspan: tspan}
  end

  @[AC::Route::POST("/reload")]
  def reload(pdict : String = "combine")
    start = Time.monotonic
    ai_mt = AiCore.new(pdict)

    input = self._read_body.lines(chomp: true)
    trees = input.map { |line| ai_mt.translate!(RawCon.from_text(line)) }

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    json = {lines: trees, tspan: tspan}

    render json: json
  rescue ex
    Log.error(exception: ex) { input }
    render 455, ex.message
  end
end
