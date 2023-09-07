# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"
require "./ai_tran_util"

class MT::AiTranCtrl < AC::Base
  base "/_ai/qtran"

  @[AC::Route::GET("/wnchap")]
  def wn_chap(cpath : String, pdict : String = "combine", _mode : Int32 = 0)
    _algo = _read_cookie("c_algo") || "auto"
    _auto = _cfg_enabled?("c_auto") && _privi > 1

    cdata, _algo = AiTranUtil.load_chap_con_data(cpath, _algo, _auto)

    ai_mt = AiCore.new(pdict, true)

    output = JSON.build do |jb|
      jb.array do
        cdata.each_line do |line|
          ai_mt.tl_from_con_data(line).to_cjo(jb: jb) unless line.empty?
        end
      end
    end

    response.headers["_ALGO"] = _algo
    render text: output
  rescue ex
    Log.error(exception: ex) { [cpath, pdict] }
    render 455, ex.message
  end

  # @[AC::Route::GET("/debug/ztext")]
  # def debug(ztext : String, pdict : String = "rand/fixture")
  #   _algo = _read_cookie("c_algo") || "auto"
  #   cdata = AiTranUtil.get_con_data_from_hanlp(ztext, _algo)

  #   aidata = AiCore.new(pdict, true).tl_from_con_data(cdata)

  #   output = {
  #     ztext: ztext,
  #     cdata: cdata,

  #     cjo_a: aidata.to_cjo(true, false),
  #     mtl_b: AiTranUtil.get_v1_qtran_mtl(ztext, pdict),
  #     txt_b: AiTranUtil.call_free_btran(ztext, "bzv"),
  #   }

  #   render json: output
  # end

  # TODO: reimplement this
  # @[AC::Route::POST("/preview")]
  # def preview(cdata : String, pdict : String = "rand/fixture")
  #   aidata = AiCore.new(pdict, true).tl_from_con_data(cdata)

  #   output = {
  #     ztext: aidata.zstr,
  #     cdata: cdata,

  #     mtl_a: aidata.to_mtl(true, false),
  #     mtl_b: AiTranUtil.get_v1_qtran_mtl(aidata.zstr, pdict),
  #     txt_b: AiTranUtil.call_free_btran(aidata.zstr),
  #   }

  #   render json: output
  # end
end
