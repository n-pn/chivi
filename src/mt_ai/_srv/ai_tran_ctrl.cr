require "./_mt_ctrl_base"
require "../data/m_cache"

class MT::AiTranCtrl < AC::Base
  base "/_ai"

  ALGOS = {"mtl_0", "mtl_1", "mtl_2", "mtl_3"}

  @[AC::Route::GET("/qtran")]
  def qfile(fpath : String, pdict : String = "combine", udict : String = "",
            qtype : String = "mtl_1", h_sep : UInt32 = 1_u32)
    ztext = File.read_lines("var/texts/#{fpath}.raw.txt", chomp: true)
    qdata = do_qtran(ztext, pdict, udict, qtype, h_sep: h_sep)

    cache_control 3.seconds
    render json: qdata
  rescue ex
    status = ex.message == "404" ? 404 : 500
    Log.error(exception: ex) { [fpath, pdict] }
    render status, json: [] of String
  end

  @[AC::Route::POST("/qtran")]
  def qtext(pdict : String = "combine", udict : String = "",
            qtype : String = "mtl_1", h_sep : UInt32 = 1_u32)
    ztext = self._read_body.lines(chomp: true)
    qdata = do_qtran(ztext, pdict, udict, qtype, h_sep: h_sep)
    render json: qdata
  rescue ex
    Log.error(exception: ex) { ztext }
    render 455, ex.message
  end

  private def do_qtran(input : Array(String), pdict : String, udict : String,
                       m_alg : String, h_sep : UInt32)
    heads = [] of MtNode | Nil

    h_sep.times do |index|
      title, split = TlChap.split(input[index])
      input[index] = title
      heads << split
    end

    ai_mt = udict.empty? ? AiCore.load(pdict) : AiCore.load(pdict, udict)
    zdata = MCache.find_con!(input, ver: m_alg[-1].to_i16)

    zdata.map_with_index do |line, l_id|
      ai_mt.translate!(line, prfx: heads[l_id]?)
    end
  end

  @[AC::Route::POST("/reload")]
  def reload(pdict : String = "combine")
    start = Time.monotonic
    ai_mt = AiCore.load(pdict, "qt#{self._vu_id}")

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
