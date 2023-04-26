require "./_sp_ctrl_base"

require "../../mtapp/sp_core"
require "../../mtapp/qt_core"

require "../../mtapp/service/*"
require "../../_data/logger/qtran_xlog"

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
    sp_mt = MT::SpCore.sino_vi
    plain = mode != "mtl"

    output = String.build do |io|
      _read_body.each_line do |line|
        data = sp_mt.tokenize(line)
        plain ? data.to_txt(io, cap: cap_first) : data.to_mtl(io, cap: cap_first)
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

  @[AC::Route::GET("/bing_chap/:hash")]
  def bing_chap(hash : String, wn_id : Int32 = 0, format = "mtl", label : String? = nil)
    zh_path = "/www/chivi/tmp/#{_uname}-#{hash}.txt"
    bv_path = "/www/chivi/txt/btran/#{hash}.txt"

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

  @[AC::Route::GET("/tl_chap/:hash")]
  def tl_chap(hash : String, wn_id : Int32 = 0, format = "mtl", label : String? = nil)
    ztext = File.read("/www/chivi/tmp/#{_uname}-#{hash}.txt")
    plain = format == "txt"

    qt_mt = MT::QtCore.new(wn_id, user: @w_user)

    spawn do
      ihash = HashUtil.decode32(hash).to_u32.unsafe_as(Int32)
      isize = ztext.size
      log_tran_stats(ihash, isize, wn_id, w_udic: !@w_user.empty?)
    end

    cvmtl = String.build do |io|
      start = Time.monotonic

      ztext.each_line do |line|
        data = qt_mt.tokenize(line)
        plain ? data.to_txt(io) : data.to_mtl(io)
        io << '\n'
      end

      io << "\n$\t$\t$\n"

      tspan = Time.monotonic - start
      tspan = tspan.total_milliseconds.round.to_i
      io << tspan << '\t' << "-" << '\t' << "-"
    end

    render json: {cvmtl: cvmtl, ztext: ztext}
  end

  private def log_tran_stats(ihash : Int32, isize : Int32, wn_dic : Int32, w_udic = true)
    xlog = CV::QtranXlog.new(
      input_hash: ihash, char_count: isize, viuser_id: _vu_id,
      wn_dic: wn_dic, w_udic: w_udic,
      mt_ver: 0_i16, cv_ner: false,
      ts_sdk: false, ts_acc: false,
    ).create!

    time_now = Time.local
    log_file = "var/ulogs/qtlog/#{time_now.to_s("%F")}.log"

    File.open(log_file, "a", &.puts(xlog.to_json))
  end
end
