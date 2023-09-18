require "../../mt_ai/core/qt_core"
require "./_sp_ctrl_base"
require "../util/*"

# require "../../_data/logger/qtran_xlog"

class SP::TranCtrl < AC::Base
  base "/_sp"

  TEXT_DIR = "var/wnapp/chtext"
  TRAN_DIR = "var/wnapp/chtran"

  private def gen_fpath(zpath : String, ftype : String)
    case ftype
    when "nctext" then "#{TEXT_DIR}/#{zpath}.txt"
    else               raise "unsupported!"
    end
  end

  @[AC::Route::GET("/hviet")]
  def hviet_file(zpath : String, ftype = "nctext", w_raw : Bool = true)
    start = Time.monotonic

    ztext = File.read_lines(gen_fpath(zpath, ftype), chomp: true)
    hviet = ztext.map { |line| MT::HvietToVarr.new(MT::QtCore.hv_word.tokenize(line)) }
    tspan = (Time.monotonic - start).total_milliseconds.to_i

    if w_raw
      render json: {hviet: hviet, tspan: tspan, ztext: ztext}
    else
      render json: {hviet: hviet, tspan: tspan}
    end
  rescue ex
    Log.error(exception: ex) { ex.message }
    render json: {hviet: [] of String, tspan: 0, eror: ex.message}
  end

  @[AC::Route::PUT("/hviet")]
  def hviet_text(mode : String = "mtl", cap : Bool = true)
    sp_mt = MT::QtCore.hv_word
    plain = mode != "mtl"

    output = String.build do |io|
      _read_body.each_line do |line|
        data = sp_mt.tokenize(line)
        plain ? data.to_txt(io, cap: cap) : data.to_mtl(io, cap: cap)
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
