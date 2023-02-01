require "../_ctrl_base"
require "../shared/qtran_data"
require "../../../_util/tran_util"
require "../../../mt_v1/data/v1_dict"

class CV::QtransCtrl < CV::BaseCtrl
  base "/"

  struct SpecForm
    include JSON::Serializable

    getter input : String
    getter dname : String = "combine"
    getter uname : String? = nil
  end

  @[AC::Route::PUT("/_db/qtran/mterror", body: :form)]
  def mtspec(form : SpecForm, _caps : Bool = false)
    cvmtl = MtCore.generic_mtl(form.dname, form.uname || _viuser.uname)

    output = String.build do |io|
      cvmtl.cv_plain(form.input, cap_first: _caps).to_txt(io)
      io << '\n'
      MtCore.hanviet_mtl.translit(form.input, _caps)
    end

    render text: output
  end

  @[AC::Route::GET("/_db/qtran/:type/:name")]
  def cached(type : String, name : String,
             user : String = _uname,
             trad : Bool = false,
             temp : Bool = false,
             _raw : Bool = false,
             _new : Bool = false,
             format : QtranData::Format = QtranData::Format::Html)
    stale = _new ? Time.utc + 10.minutes : Time.utc
    data = QtranData.load!(type, name, stale: stale)

    raise NotFound.new("Not found!") if data.input.empty?

    engine = data.make_engine(user, with_temp: temp)

    output = String.build do |io|
      data.print_mtl(engine, io, format: format, title: type == "chaps", trad: trad)
      data.print_raw(io) if _raw
    end

    render text: output
  end

  struct PostForm
    include JSON::Serializable

    getter input : String
    getter dname : String = "combine"

    def validate!
      raise BadRequest.new("Dữ liệu quá lớn") if @input.size > 10000
    end
  end

  @[AC::Route::POST("/_db/qtran/posts", body: :form)]
  def posts_upsert(form : PostForm)
    # TODO: save posts

    form.validate!

    lines = QtranData.parse_lines(form.input)
    d_lbl = QtranData.get_d_lbl(form.dname)

    data = QtranData.new(lines, form.dname, d_lbl)
    ukey = params["ukey"]? || QtranData.post_ukey

    data.save!(ukey)
    QtranData::CACHE.set("posts/" + ukey, data)

    render json: {ukey: ukey}
  end

  record ConvertForm, input : String do
    include JSON::Serializable

    def after_initialize
      @input = @input.tr("\t", " ")
    end

    def validate!(privi = -1)
      max_size = 2 ** (privi + 1) * 1000
      return if input.size < max_size
      raise BadRequest.new "Dữ liệu đầu vào vượt quá giới hạn cho phép (#{input.size}/#{max_size})"
    end
  end

  enum RenderTitle
    None; First; All
  end

  @[AC::Route::POST("/api/qtran", body: :form)]
  @[AC::Route::POST("/_db/qtran", body: :form)]
  def cv_post(form : ConvertForm,
              dname : String = "combine")
    form.validate!(_privi)
    cvmtl = MtCore.generic_mtl(dname, _viuser.uname)

    output = String.build do |str|
      form.input.each_line do |line|
        cvmtl.cv_plain(line).to_txt(str)
        str << '\n'
      end
    end

    render text: output
  end

  @[AC::Route::POST("/_db/cv_chap")]
  def cv_chap(wn_id : Int32 = 0, cv_title : String = "none", label : String? = nil)
    dname = M1::DbDict.get_dname(-wn_id)
    cvmtl = MtCore.generic_mtl(dname, _viuser.uname)

    render_title = RenderTitle.parse(cv_title)
    input = request.body.not_nil!.gets_to_end

    output = String.build do |str|
      stime = Time.monotonic

      iter = input.each_line
      head = iter.next.as(String)
      head += " #{label}" if label

      mtl = !render_title.none? ? cvmtl.cv_title(head) : cvmtl.cv_plain(head)
      mtl.to_mtl(str)

      iter.each do |line|
        str << '\n'

        mtl = render_title.all? ? cvmtl.cv_title(line) : cvmtl.cv_plain(line)
        mtl.to_mtl(str)
      end

      tspan = (Time.monotonic - stime).total_milliseconds.round.to_i
      dsize = cvmtl.dicts.last.size

      str << "\n$\t$\t$\n" << tspan << '\t' << dsize << '\t' << dname
    end

    render text: output
  end
end
