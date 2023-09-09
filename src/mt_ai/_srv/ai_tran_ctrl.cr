# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"
require "./ai_tran_util"

class MT::AiTranCtrl < AC::Base
  base "/_ai/mt"

  @[AC::Route::GET("/wnchap")]
  def wnchap(cpath : String, pdict : String = "combine", _algo : String = "avail")
    _auto_gen = _privi > 1 && _cfg_enabled?("c_auto")
    input, ctime, _algo = AiTranUtil.get_wntext_con_data(cpath, _algo, _auto_gen)

    ai_mt = AiCore.new(pdict)
    cdata = input.map { |line| ai_mt.tl_from_con_data(line) }

    render json: [cdata, ctime, _algo]
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
