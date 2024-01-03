require "./_m1_ctrl_base"
require "./m1_tran_data"
require "../../mt_ai/core/qt_core"
require "../../rdapp/data/chinfo"

class M1::TranCtrl < AC::Base
  base "/_m1/qtran"

  @[AC::Route::POST("/")]
  def qtran_text(wn_id : Int32 = 0, title : Int32 = 1,
                 fpath : String = "", format = "txt")
    mcore = MtCore.init(wn_id, user: _uname)
    vtran = String.build do |io|
      self.each_body_line do |line|
        data = title == 0 ? mcore.cv_plain(line) : mcore.cv_chead(line)
        format == "mtl" ? data.to_mtl(io) : data.to_txt(io)
        io << '\n'
        title &-= 1
      end
    end

    render text: vtran
  end

  @[AC::Route::GET("/cached")]
  def cached(type : String, name : String, wn_id : Int32 = 0, format = "mtl")
    qtran = TranData.load_cached(type, name, wn_id, format)
    cvmtl = qtran.cv_wrap(_uname) { |io, engine| cv_post(io, engine) }

    render json: {cvmtl: cvmtl, ztext: qtran.input, wn_id: wn_id}
  end

  @[AC::Route::GET("/btitle")]
  def btitle(ztext : String, wn_id : Int32 = 0)
    vtext = TlUtil.tl_btitle(ztext, wn_id)
    render text: vtext
  end

  @[AC::Route::GET("/author")]
  def author(ztext : String)
    vtext = TlUtil.tl_author(ztext)
    render text: vtext
  end

  @[AC::Route::GET("/hvname")]
  def hvname(ztext : String)
    vtext = MT::QtCore.tl_hvname(ztext)
    render text: vtext
  end

  record WninfoForm, btitle : String, author : String, bintro : String do
    include JSON::Serializable
  end

  @[AC::Route::POST("/wndata", body: :form)]
  def wndata(form : WninfoForm, wn_id : Int32 = 0)
    cv_mt = MtCore.init(wn_id, user: _uname)

    intro = String.build do |io|
      form.bintro.each_line do |line|
        cv_mt.cv_plain(line, true).to_txt(io)
        io << '\n'
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

  @[AC::Route::GET("/suggest")]
  def suggest(input : String, wn_id : Int32 = 0, w_cap : Bool = false)
    guard_privi 0, "dùng máy dịch v1"

    cv_mt = MtCore.init(wn_id, user: _uname)
    otext = cv_mt.cv_plain(input, w_cap).to_txt
    render text: otext
  end

  @[AC::Route::POST("/cv_chap")]
  def cv_chap(wn_id : Int32 = 0, w_title : Bool = true, label : String? = nil)
    guard_privi 0, "dùng máy dịch v1"

    input = request.body.try(&.gets_to_end) || ""
    qtran = TranData.new(input, wn_id, format: "mtl")

    cvmtl = qtran.cv_wrap do |io, engine|
      cv_chap(io, engine, w_title, label)
    end

    render text: cvmtl
  end

  @[AC::Route::PUT("/tl_mulu")]
  def tl_mulu(ch_db : String, wn_id : Int32 = 0, start : Int32 = 1, limit : Int32 = 99999)
    cv_mt = MtCore.init(wn_id)

    vtran = Hash(String, String).new do |hash, zstr|
      vstr = cv_mt.cv_chead(TextUtil.normalize(zstr)).to_txt
      hash[zstr] = vstr
    end

    crepo = RD::Chinfo.db(ch_db)
    clist = RD::Chinfo.get_all(crepo, start: start, limit: limit &+ 1)

    clist.each do |cinfo|
      cinfo.vtitle = vtran[cinfo.ztitle]
      cinfo.vchdiv = vtran[cinfo.zchdiv]
    end

    RD::Chinfo.update_vinfos!(crepo, clist)

    render text: "ok"
  end
end
