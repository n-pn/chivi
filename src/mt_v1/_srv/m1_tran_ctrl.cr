require "./_m1_ctrl_base"

class M1::TranCtrl < AC::Base
  base "/_m1/qtran"

  @[AC::Route::GET("/")]
  def qt_line(zh ztext : String, wn wn_id : Int32 = 0, wc w_cap : Bool = false)
    cv_mt = MtCore.new(wn_id)
    otext = cv_mt.cv_plain(ztext, w_cap).to_txt
    render text: otext
  end

  @[AC::Route::POST("/")]
  def qt_para(wn wn_id : Int32 = 0, hs h_sep : Int32 = 1)
    vtran = String.build do |io|
      mcore = MtCore.new(wn_id)

      self.each_body_line do |line|
        unless line.empty?
          data = h_sep > 0 ? mcore.cv_chead(line) : mcore.cv_plain(line)
          data.to_txt(io)
        end

        io << '\n'
        h_sep &-= 1
      end
    end

    render text: vtran
  end

  record WninfoForm, btitle : String, author : String, bintro : String do
    include JSON::Serializable
  end

  @[AC::Route::POST("/wndata", body: :form)]
  def wndata(form : WninfoForm, wn_id : Int32 = 0)
    cv_mt = MtCore.new(wn_id)

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
end
