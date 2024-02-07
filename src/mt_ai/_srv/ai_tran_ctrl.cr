require "./_mt_ctrl_base"
require "../data/m_cache"

class MT::AiTranCtrl < AC::Base
  base "/_ai"

  # @[AC::Route::GET("/qtran")]
  # def qfile(fpath : String,
  #           qtype : String = "mtl_1", otype : String = "json",
  #           pdict : String = "combine", udict : String = "",
  #           h_sep : UInt32 = 1_u32)
  #   ztext = File.read_lines("var/texts/#{fpath}.raw.txt", chomp: true)
  #   qdata = do_qtran(ztext, qtype, otype, pdict, udict, h_sep: h_sep)

  #   cache_control 3.seconds
  #   render json: qdata
  # rescue ex
  #   status = ex.message == "404" ? 404 : 500
  #   Log.error(exception: ex) { [fpath, pdict] }
  #   render status, json: [] of String
  # end

  ALGOS = {"mtl_0", "mtl_1", "mtl_2", "mtl_3"}

  @[AC::Route::POST("/qtran")]
  def qtext(qt qtype : String = "mtl_1", op otype : String = "json",
            pd pdict : String = "combine", ud udict : String = "",
            hs h_sep : UInt32 = 1_u32, ls l_sep : UInt32 = 0_u32)
    # raise "invalid!" unless self.client_ip == "127.0.0.1"

    zdata = self._read_body.lines(chomp: true)
    heads = [] of MtNode | Nil

    h_sep.times do |index|
      title, split = TlChap.split(zdata[index])
      zdata[index] = title
      heads << split
    end

    cdata = MCache.find_con!(zdata, ver: qtype[-1].to_i16)

    ai_mt = udict.empty? ? AiCore.load(pdict) : AiCore.load(pdict, udict)
    qdata = cdata.map_with_index { |line, l_id| ai_mt.translate!(line, prfx: heads[l_id]?) }

    if otype == "text"
      text = qdata.join('\n', &.to_txt)
      render text: text
    else
      render json: qdata
    end
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 455, ex.message
  end

  @[AC::Route::POST("/from_con")]
  def from_con(pdict : String = "combine")
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
