require "./_m1_ctrl_base"
require "./m1_tran_data"

require "../../_data/logger/qtran_xlog"
require "../../rdapp/data/chinfo"

class M1::TranCtrl < AC::Base
  base "/_m1/qtran"

  @[AC::Route::GET("/")]
  def file(fpath : String, wn_id : Int32 = 0)
    start = Time.monotonic
    mcore = MtCore.init(wn_id, user: _uname)

    plain = false
    lines = [] of String

    RD::Chpart.new(fpath).read_raw do |line|
      data = plain ? mcore.cv_plain(line) : mcore.cv_title(line)
      lines << data.to_txt
      plain = true
    end

    tspan = (Time.monotonic - start).total_milliseconds.round(2)
    mtime = Time.utc.to_unix

    cache_control 7.days
    add_etag mtime.to_s

    render json: {lines: lines, mtime: mtime, tspan: tspan}
  end

  @[AC::Route::POST("/")]
  def convert(wn_id : Int32 = 0, format = "mtl")
    input = request.body.try(&.gets_to_end) || ""

    qtran = TranData.new(input, wn_id, format)
    cvmtl = qtran.cv_wrap(_uname, w_stat: false) do |io, engine|
      cv_post(io, engine)
    end

    render text: cvmtl
  end

  @[AC::Route::GET("/cached")]
  def cached(type : String, name : String, wn_id : Int32 = 0, format = "mtl")
    qtran = TranData.load_cached(type, name, wn_id, format)
    cvmtl = qtran.cv_wrap(_uname) { |io, engine| cv_post(io, engine) }

    render json: {cvmtl: cvmtl, ztext: qtran.input, wn_id: wn_id}
  end

  @[AC::Route::GET("/wntext")]
  def qtran_wntext(cpath : String)
    vtext = String.build do |io|
      txt_path = TranData.wntext_path(cpath)

      mt_v1 = MtCore.init(cpath.split('/').first.to_i)
      first = true

      File.each_line(txt_path) do |line|
        io << '\n' unless first
        data = first ? mt_v1.cv_title(line) : mt_v1.cv_plain(line)
        data.to_txt(io)
        first = false
      end
    end

    render text: vtext
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
    cv_mt = MtCore.init(wn_id, user: _uname)

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
    cv_mt = MtCore.init(wn_id, user: _uname)
    input = request.body.try(&.gets_to_end) || ""

    output = String.build do |io|
      cv_mt.cv_plain(input, w_cap).to_txt(io)
      io << '\n'
      io << MT::QtCore.tl_hvword(input, cap: w_cap)
    end

    render text: output
  end

  @[AC::Route::POST("/cv_chap")]
  def cv_chap(wn_id : Int32 = 0, w_title : Bool = true, label : String? = nil)
    input = request.body.try(&.gets_to_end) || ""

    spawn do
      ihash = HashUtil.fnv_1a(input).unsafe_as(Int32)
      isize = input.size
      log_tran_stats(ihash, isize, wn_id)
    end

    qtran = TranData.new(input, wn_id, format: "mtl")

    cvmtl = qtran.cv_wrap(w_user: @w_user) do |io, engine|
      cv_chap(io, engine, w_title, label)
    end

    render text: cvmtl
  end

  private def log_tran_stats(ihash : Int32, isize : Int32, wn_dic : Int32)
    xlog = CV::QtranXlog.new(
      input_hash: ihash, char_count: isize, viuser_id: _vu_id,
      wn_dic: wn_dic,
      mt_ver: 1_i16, cv_ner: false,
      ts_sdk: false, ts_acc: false,
    )

    xlog.create!

    time_now = Time.local
    log_file = "var/ulogs/qtlog/#{time_now.to_s("%F")}.log"

    File.open(log_file, "a", &.puts(xlog.to_json))
  end

  @[AC::Route::PUT("/tl_mulu")]
  def tl_mulu(ch_db : String, wn_id : Int32 = 0, start : Int32 = 1, limit : Int32 = 9999)
    cv_mt = MtCore.init(wn_id)

    vtran = Hash(String, String).new do |hash, zstr|
      vstr = cv_mt.cv_title(TextUtil.normalize(zstr)).to_txt
      hash[zstr] = vstr
    end

    crepo = RD::Chinfo.db(ch_db)
    clist = RD::Chinfo.get_all(crepo, start: start, limit: limit)

    clist.each do |cinfo|
      cinfo.vtitle = vtran[cinfo.ztitle]
      cinfo.vchdiv = vtran[cinfo.zchdiv]
    end

    RD::Chinfo.update_vinfos!(crepo, clist)

    render text: "ok"
  end
end
