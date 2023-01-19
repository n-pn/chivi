require "../_ctrl_base"

class CV::TlspecCtrl < CV::BaseCtrl
  base "/_db/tlspecs"

  @[AC::Route::GET("/", converters: {lm: ConvertLimit}, config: {lm: {min: 10, max: 50}})]
  def index(pg pg_no : Int32 = 1, lm limit : Int32 = 50)
    total = Tlspec.items.size
    offset = CtrlUtil.offset(pg_no, limit)

    {
      total: total,
      pgidx: pg_no,
      pgmax: CtrlUtil.pgmax(total, limit),
      items: Tlspec.items.skip(offset).first(limit).compact_map do |ukey|
        entry = Tlspec.load!(ukey)
        last_edit = entry.edits.last
        ztext = entry.ztext[last_edit.lower...last_edit.upper]
        cvmtl = MtCore.generic_mtl(entry.dname).cv_plain(ztext, cap_first: false).to_txt

        {
          _ukey: ukey,
          ztext: ztext,
          d_dub: entry.d_dub,
          mtime: last_edit.mtime,
          uname: entry.edits.first.uname,
          privi: entry.edits.first.privi,
          match: last_edit.match,
          cvmtl: cvmtl,
        }
      end,
    }
  end

  struct SpecForm
    include JSON::Serializable
    getter ztext : String = ""
    getter dname : String = "", d_dub : String = ""

    getter lower : Int32 = 0, upper : Int32 = 0
    getter extra : String = "", match : String = ""
  end

  @[AC::Route::POST("/", body: :form)]
  def create(form : SpecForm)
    raise Unauthorized.new("Quyền hạn của bạn không đủ.") unless _viuser.can?(:level0)

    _ukey = HashUtil.gen_ukey(Time.utc)
    entry = Tlspec.new(_ukey, fresh: true)

    entry.ztext = form.ztext
    entry.dname = form.dname
    entry.d_dub = form.d_dub

    entry.add_edit!(form, _viuser)
    entry.save!

    render text: _ukey
  end

  @[AC::Route::GET("/:ukey")]
  def show(ukey : String)
    entry = Tlspec.load!(ukey)

    last_edit = entry.edits.last
    lower = last_edit.lower
    upper = last_edit.upper

    ztext = entry.ztext[lower...upper]
    dname = entry.dname

    cvmtl = MtCore.generic_mtl(dname)

    render json: {
      ztext: entry.ztext,
      lower: lower,
      upper: upper,
      dname: dname,
      d_dub: entry.d_dub,
      uname: entry.edits.first.uname,
      privi: entry.edits.first.privi,
      entry: {
        _ukey: ukey,
        match: last_edit.match,
        extra: last_edit.extra,
        cvmtl: cvmtl.cv_plain(ztext, cap_first: false).to_txt,
      },
      # edits: entry.edits,
    }
  end

  @[AC::Route::POST("/:ukey", body: :form)]
  def update(form : SpecForm, ukey : String)
    entry = Tlspec.load!(ukey)

    unless _viuser.privi > 2 || entry.edits.first.uname == _viuser.uname
      raise Unauthorized.new("Quyền hạn của bạn không đủ.")
    end

    entry.add_edit!(form, _viuser)
    entry.save!

    {msg: "ok"}
  end

  @[AC::Route::DELETE("/:ukey")]
  def delete(ukey : String)
    entry = Tlspec.load!(ukey)

    unless _viuser.privi > 2 || entry.edits.first.uname == _viuser.uname
      raise Unauthorized.new("Quyền hạn của bạn không đủ.")
    end

    entry.delete!
    {msg: "ok"}
  end
end
