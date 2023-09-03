require "./_sp_ctrl_base"

require "../../mt_ai/core/qt_core"

require "../util/*"

# require "../../_data/logger/qtran_xlog"

class SP::TranCtrl < AC::Base
  base "/_sp"

  @w_user : String = ""
  @w_init : Bool = false

  @[AC::Route::Filter(:before_action)]
  def before_all_actions
    @w_init = _cfg_enabled?("w_init")
    @w_user = _cfg_enabled?("w_udic") ? _uname : ""
  end

  @[AC::Route::PUT("/hanviet")]
  def hanviet(mode : String = "mtl", cap_first : Bool = true)
    sp_mt = MT::QtCore.hv_word
    plain = mode != "mtl"

    output = String.build do |io|
      _read_body.each_line do |line|
        data = sp_mt.tokenize(line)
        plain ? data.to_txt(io, cap: cap_first, pad: false) : data.to_mtl(io, cap: cap_first, pad: false)
        io << '\n'
      end
    end

    response.content_type = "text/plain; charset=utf-8"
    render text: output
  end

  @[AC::Route::POST("/btran")]
  def btran(sl : String = "zh", tl : String = "vi", no_cap : Bool = false)
    output = Btran.translate(_read_body.lines, source: sl, target: tl, no_cap: no_cap)

    response.content_type = "text/plain; charset=utf-8"
    render text: output.join('\n', &.[1])
  end

  @[AC::Route::POST("/deepl")]
  def deepl(sl : String = "zh", tl : String = "en", no_cap : Bool = false)
    output = Deepl.translate(_read_body.lines, source: sl, target: tl, no_cap: no_cap)

    response.content_type = "text/plain; charset=utf-8"
    render text: output.join('\n', &.[1])
  end

  TEXT_DIR = "var/wnapp/chtext"
  TRAN_DIR = "var/wnapp/chtran"

  @[AC::Route::GET("/bing_chap")]
  def wnchap_bzv(cpath : String, wn_id : Int32 = 0, label : String? = nil)
    zh_path = "#{TEXT_DIR}/#{cpath}.txt"
    bv_path = "#{TRAN_DIR}/#{cpath}.bzv.txt"
    # Dir.mkdir_p(File.dirname(bv_path))

    ztext = File.read(zh_path).lines

    if stat = File.info?(bv_path)
      btran = File.read_lines(bv_path)
      mtime = stat.modification_time.to_unix
    else
      btran = Btran.free_translate(ztext, target: "vi")
      File.write(bv_path, btran.join('\n'))
      mtime = Time.utc.to_unix
    end

    render json: {btran: btran, ztext: ztext, mtime: mtime}
  end

  @[AC::Route::GET("/btran/wntext")]
  def btran_wntext(cpath : String)
    bzv_path = "#{TRAN_DIR}/#{cpath}.bzv.txt"

    if File.file?(bzv_path)
      btran = File.read(bzv_path)
    else
      ztext = File.read_lines("#{TEXT_DIR}/#{cpath}.txt")
      btran = Btran.free_translate(ztext, target: "vi").join('\n')
      File.write(bzv_path, btran)
    end

    render text: btran
  end
end
