# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"

class MT::AiTranCtrl < AC::Base
  base "/_ai/qtran"

  WN_TXT_DIR = "var/wnapp/chtext"
  WN_NLP_DIR = "var/wnapp/nlp_wn"

  @[AC::Route::GET("/wnchap")]
  def wn_chap(cpath : String,
              pdict : String = "combined",
              _mode : Int32 = 0)
    con_path = "#{WN_NLP_DIR}/#{cpath}.hmeb.con"

    unless File.file?(con_path)
      # txt_path = "#{WN_TXT_DIR}/#{cpath}.txt"
      # TODO: call hanlp_srv
      render :not_found, "Chưa có dữ liệu trên hệ thống!"
      return
    end

    engine = AiCore.new(pdict, true)

    ztext = String::Builder.new
    cvmtl = String::Builder.new

    cdata = File.read(con_path)

    cdata.each_line(con_path) do |line|
      next if line.empty?
      data = engine.tl_from_con_data(line)

      ztext << data.zstr
      data.to_mtl(io: cvmtl, cap: true, pad: false)

      ztext << '\n'
      cvmtl << '\n'
    end

    output = {cvmtl: cvmtl.to_s, ztext: ztext.to_s, cdata: cdata}
    render json: output
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
