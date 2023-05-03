require "./_m1_ctrl_base"
require "./m1_tran_data"

require "../../mtapp/sp_core"
require "../../_data/logger/qtran_xlog"

class M1::TranCtrl < AC::Base
  base "/_m1/qtran"

  @w_user : String = ""
  @w_init : Bool = false

  @[AC::Route::Filter(:before_action)]
  def before_action
    @w_init = _read_cookie("w_init").try(&.starts_with?('t')) || false
    w_udic = _read_cookie("w_udic").try(&.starts_with?('t')) || false
    @w_user = w_udic ? _uname : ""
  end

  @[AC::Route::POST("/")]
  def convert(wn_id : Int32 = 0, format = "mtl")
    input = request.body.try(&.gets_to_end) || ""

    # if input.size > limit
    #   render :bad_request, "Nội dung vượt quá giới hạn cho phép (#{input.size}/#{limit})"
    #   return
    # end

    qtran = TranData.new(input, wn_id, format)
    cvmtl = qtran.cv_wrap(_uname, w_init: @w_init, w_stat: false) do |io, engine|
      cv_post(io, engine)
    end

    render text: cvmtl
  end

  @[AC::Route::GET("/cached")]
  def cached(type : String, name : String, wn_id : Int32 = 0, format = "mtl")
    qtran = TranData.load_cached(type, name, wn_id, format)
    cvmtl = qtran.cv_wrap(_uname, w_init: @w_init) { |io, engine| cv_post(io, engine) }

    render json: {cvmtl: cvmtl, ztext: qtran.input, wn_id: wn_id}
  end

  @[AC::Route::GET("/wnchap/:hash")]
  def tl_wnchap(hash : String, wn_id : Int32 = 0, format = "mtl", label : String? = nil)
    qtran = TranData.load_cached("chaps", "#{_uname}-#{hash}", wn_id, format)

    spawn do
      ihash = HashUtil.decode32(hash).to_u32.unsafe_as(Int32)
      isize = qtran.input.size
      log_tran_stats(ihash, isize, wn_id, w_udic: !@w_user.empty?)
    end

    cvmtl = qtran.cv_wrap(w_user: @w_user, w_init: @w_init) do |io, engine|
      cv_chap(io, engine, w_title: true, label: label)
    end

    render json: {cvmtl: cvmtl, ztext: qtran.input}
  end

  @[AC::Route::GET("/tl_btitle")]
  def tl_btitle(btitle : String, wn_id : Int32 = 0)
    render text: TlUtil.tl_btitle(btitle, wn_id)
  end

  @[AC::Route::GET("/tl_author")]
  def tl_author(author : String)
    render text: TlUtil.tl_author(author)
  end

  record WninfoForm, btitle : String, author : String, bintro : String do
    include JSON::Serializable
  end

  @[AC::Route::POST("/tl_wnovel", body: :form)]
  def tl_wnovel(form : WninfoForm, wn_id : Int32 = 0)
    cv_mt = MtCore.init(wn_id, user: _uname, init: @w_init)

    intro = String.build do |io|
      form.bintro.each_line.with_index do |line, idx|
        io << '\n' if idx > 0
        cv_mt.cv_plain(line, true).to_txt(io)
      end
    end

    render json: {
      btitle: TlUtil.tl_btitle(form.btitle, wn_id),
      author: TlUtil.tl_author(form.author),
      bintro: intro,
    }
  end

  private def post_limit(privi = _privi)
    2 ** (privi &+ 1) &* 1000 &+ 1000
  end

  TMP_DIR = "tmp/qtran"
  Dir.mkdir_p(TMP_DIR)

  @[AC::Route::POST("/posts")]
  def create_post
    input = TextUtil.split_html(_read_body).join('\n')
    raise BadRequest.new("Dữ liệu quá lớn") if input.size > post_limit(_privi)

    pname = HashUtil.uniq_hash(input)
    File.write("#{TMP_DIR}/#{pname}.txt", input)

    render text: pname
  end

  @[AC::Route::PUT("/debug")]
  def debug(wn_id : Int32, w_cap : Bool = false)
    cv_mt = MtCore.init(wn_id, user: _uname, init: @w_init)
    input = request.body.try(&.gets_to_end) || ""

    output = String.build do |io|
      cv_mt.cv_plain(input, w_cap).to_txt(io)
      io << '\n'
      io << MT::SpCore.tl_sinovi(input, cap: w_cap)
    end

    render text: output
  end

  @[AC::Route::POST("/cv_chap")]
  def cv_chap(wn_id : Int32 = 0, w_title : Bool = true, label : String? = nil)
    input = request.body.try(&.gets_to_end) || ""

    spawn do
      ihash = HashUtil.fnv_1a(input).unsafe_as(Int32)
      isize = input.size
      log_tran_stats(ihash, isize, wn_id, w_udic: !@w_user.empty?)
    end

    qtran = TranData.new(input, wn_id, format: "mtl")

    cvmtl = qtran.cv_wrap(w_user: @w_user, w_init: @w_init) do |io, engine|
      cv_chap(io, engine, w_title, label)
    end

    render text: cvmtl
  end

  private def log_tran_stats(ihash : Int32, isize : Int32, wn_dic : Int32, w_udic = true)
    xlog = CV::QtranXlog.new(
      input_hash: ihash, char_count: isize, viuser_id: _vu_id,
      wn_dic: wn_dic, w_udic: w_udic,
      mt_ver: 1_i16, cv_ner: false,
      ts_sdk: false, ts_acc: false,
    )

    xlog.create!

    time_now = Time.local
    log_file = "var/ulogs/qtlog/#{time_now.to_s("%F")}.log"

    File.open(log_file, "a", &.puts(xlog.to_json))
  end

  @[AC::Route::POST("/tl_mulu")]
  def tl_mulu(wn_id : Int32 = 0)
    input = request.body.try(&.gets_to_end) || ""
    cv_mt = MtCore.init(wn_id)

    lines = String.build do |str|
      input.each_line do |line|
        cv_mt.cv_title(line).to_txt(str) unless line.empty?
        str << '\n'
      end
    end

    render text: lines
  end
end
