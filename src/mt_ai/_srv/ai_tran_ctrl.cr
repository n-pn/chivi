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

    ztext = String::Builder.new
    cvmtl = String::Builder.new

    ai_mt = AiCore.new(pdict, true)

    cdata.each_line do |line|
      next if line.empty?
      data = ai_mt.tl_from_con_data(line)

      ztext << data.zstr
      data.to_mtl(io: cvmtl, cap: true, und: true)

      ztext << '\n'
      cvmtl << '\n'
    end

    if _cfg_enabled?("view_dual")
      kind = _read_cookie("dual_kind") || "bzv"
      txt_2 = AiTranUtil.read_dual_wntext(cpath, kind)
    else
      txt_2 = ""
    end

    output = {
      ztext: ztext.to_s,

      mtl_1: cvmtl.to_s,
      txt_2: txt_2,

      cdata: cdata,
      _algo: _algo,

    }
    render json: output
  rescue ex
    Log.error(exception: ex) { [cpath, _algo] }
    render 455, "Chương tiết chưa được phân tích!"
  end

  @[AC::Route::GET("/debug/ztext")]
  def debug(ztext : String, pdict : String = "rand/fixture")
    _algo = _read_cookie("c_algo") || "auto"
    cdata = AiTranUtil.get_con_data_from_hanlp(ztext, _algo)

    aidata = AiCore.new(pdict, true).tl_from_con_data(cdata)

    output = {
      ztext: ztext,
      cdata: cdata,

      mtl_a: aidata.to_mtl(true, false),
      mtl_b: AiTranUtil.get_v1_qtran_mtl(ztext, pdict),
      txt_b: AiTranUtil.call_free_btran(ztext, "bzv"),
    }

    render json: output
  end

  @[AC::Route::GET("/debug/cdata")]
  def debug(cdata : String, pdict : String = "rand/fixture")
    aidata = AiCore.new(pdict, true).tl_from_con_data(cdata)

    output = {
      ztext: aidata.zstr,
      cdata: cdata,

      mtl_a: aidata.to_mtl(true, false),
      mtl_b: AiTranUtil.get_v1_qtran_mtl(aidata.zstr, pdict),
      txt_b: AiTranUtil.call_free_btran(aidata.zstr),
    }

    render json: output
  end
end
