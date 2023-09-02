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

    output = {cvmtl: cvmtl.to_s, ztext: ztext.to_s, cdata: cdata, _algo: _algo}
    render json: output
  rescue ex
    puts ex
    render 400, "Chương tiết không tồn tại!"
  end

  private def read_con_data(cpath : String, _algo = "auto")
    hmeg_path = "#{WN_NLP_DIR}/#{cpath}.hmeg.con"
    hmeb_path = "#{WN_NLP_DIR}/#{cpath}.hmeb.con"

    case
    when _algo == "hmeg"
      {File.read(hmeg_path), _algo}
    when _algo == "hmeb"
      {File.read(hmeb_path), _algo}
    when File.file?(hmeg_path)
      {File.read(hmeg_path), "hmeg"}
    else
      {File.read(hmeb_path), "hmeb"}
    end
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
