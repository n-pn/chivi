# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"

class MT::AiTranCtrl < AC::Base
  base "/_ai/qtran"

  WN_TXT_DIR = "var/wnapp/chtext"
  WN_NLP_DIR = "var/wnapp/nlp_wn"

  @[AC::Route::GET("/wnchap")]
  def wn_chap(cpath : String, pdict : String = "combined", _mode : Int32 = 0)
    _algo = _read_cookie("c_algo") || "auto"
    cdata, _algo = read_con_data(cpath, _algo)

    ztext = String::Builder.new
    cvmtl = String::Builder.new

    ai_mt = AiCore.new(pdict, true)

    cdata.each_line do |line|
      next if line.empty?
      data = ai_mt.tl_from_con_data(line)

      ztext << data.zstr
      data.to_mtl(io: cvmtl, cap: true, pad: false)

      ztext << '\n'
      cvmtl << '\n'
    end

    if _cfg_enabled?("view_dual")
      txt_2 = read_dual_txt(cpath, _read_cookie("dual_kind") || "bzv")
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

  private def read_dual_txt(cpath : String, _kind : String = "bzv") : String
    case _kind
    when "bzv"
      url = "#{CV_ENV.sp_host}/_sp/btran/wntext?cpath=#{cpath}"
    when "old"
      url = "#{CV_ENV.m1_host}/_m1/qtran/wntext?cpath=#{cpath}"
    else
      raise "invalid dual_kind #{_kind}"
    end

    HTTP::Client.get(url, &.body_io.gets_to_end)
  end

  private def read_con_data(cpath : String, _algo : String = "auto")
    if _algo == "auto"
      path = "#{WN_NLP_DIR}/#{cpath}.hmeg.con"
      return {File.read(path), "hmeg"} if File.file?(path)
      _algo = "hmeb"
    elsif !_algo.in?("hmeg", "hmeb")
      _algo = "hmeb"
    end

    con_path = "#{WN_NLP_DIR}/#{cpath}.#{_algo}.con"

    unless File.file?(con_path)
      Dir.mkdir_p(File.dirname(con_path))
      _auto = _cfg_enabled?("c_auto") && _privi > 1
      raise "not found" unless _auto
      call_hanlp_srv(cpath, _algo)
    end

    {File.read(con_path), _algo}
  end

  private def call_hanlp_srv(cpath : String, _algo : String)
    file = "#{WN_TXT_DIR}/#{cpath}.txt"

    link = "http://localhost:5555/#{_algo}/file?file=#{file}"
    res = HTTP::Client.get(link)
    raise "error: #{res.body}" unless res.status.success?
  end

  # @[AC::Route::POST("/qtran")]
  # def qtran(udict : Int32, format : String = "txt", apply_cap : Bool = true)
  #   w_udic = cookies["w_udic"]?.try(&.value) || "f"

  #   engine = Engine.new(udict, user: _uname, temp: w_udic == "t")
  #   to_mtl = format == "mtl"

  #   input = request.body.not_nil!.gets_to_end
  #   lines = input.split("\n", remove_empty: true).map!(&.strip)

  #   @render_called = true
  #   res = @context.response

  #   res.status_code = 200
  #   res.content_type = "text/plain; charset=utf-8"

  #   if title = lines.shift?
  #     # data = has_title ? engine.cv_title_full(title) : engine.cv_plain(title)
  #     data = engine.cv_plain(title)
  #     to_mtl ? data.to_mtl(res, apply_cap) : data.to_txt(res, apply_cap)
  #   end

  #   lines.each do |line|
  #     res << '\n'
  #     # puts line.colorize.yellow
  #     data = engine.cv_plain(line)
  #     to_mtl ? data.to_mtl(res, apply_cap) : data.to_txt(res, apply_cap)
  #   rescue err
  #     Log.error(exception: err) { line }
  #     res << "Lỗi máy dịch!"
  #   end
  # end
end
