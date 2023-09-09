# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"
require "./ai_tran_util"

class MT::QtTranCtrl < AC::Base
  base "/_ai/qt"

  # @[AC::Route::GET("/wnchap")]
  # def wn_chap(cpath : String, pdict : String = "combine", _mode : Int32 = 0)
  #   _algo = _read_cookie("c_algo") || "auto"
  #   _auto = _cfg_enabled?("c_auto") && _privi > 1

  #   cdata, _algo = AiTranUtil.load_chap_con_data(cpath, _algo, _auto)

  #   ai_mt = AiCore.new(pdict, true)

  #   output = JSON.build do |jb|
  #     jb.array do
  #       cdata.each_line do |line|
  #         ai_mt.tl_from_con_data(line).to_cjo(jb: jb) unless line.empty?
  #       end
  #     end
  #   end

  #   response.headers["_ALGO"] = _algo
  #   render text: output
  # rescue ex
  #   Log.error(exception: ex) { [cpath, pdict] }
  #   render 455, ex.message
  # end
end
