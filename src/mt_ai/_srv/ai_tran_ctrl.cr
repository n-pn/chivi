require "./_mt_ctrl_base"
require "../data/m_cache"
require "../core/text_cut"

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
            hs h_sep : UInt32 = 1_u32, rg regen : Int32 = 0)
    # raise "invalid!" unless self.client_ip == "127.0.0.1"

    bases, texts, l_ids = TextCut.split_ztext(self._read_body.strip)
    ai_mt = udict.empty? ? AiCore.load(pdict) : AiCore.load(pdict, udict)

    cv_mtime = TimeUtil.cv_mtime
    min_time = {0, cv_mtime &- 20160, cv_mtime &- 2}.fetch(regen, 0)

    mcons = MCache.find_con!(texts, ver: qtype[-1].to_i16, min_time: min_time)
    mcons.each_with_index do |cdata, c_id|
      base_node, base_body = bases[l_ids[c_id]]
      curr_node = ai_mt.translate!(cdata, from: base_body.last?.try(&.upto) || 0)
      curr_node.each_child { |node| base_body << node }
    end

    vdata = String.build do |io|
      bases.each do |bnode, _|
        otype == "txt" ? bnode.to_txt(io, cap: true, und: true) : bnode.to_mtl(io)
        io << '\n'
      end
    end

    render text: vdata
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
