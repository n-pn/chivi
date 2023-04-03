require "../_ctrl_base"
require "../../../_util/mail_util"

class CV::UsercpCtrl < CV::BaseCtrl
  base "/_db/_self"

  @[AC::Route::GET("/")]
  def profile
    _viuser.check_privi!
    response.headers["Cache-Control"] = "private, max-age=5, stale-while-revalidate"

    save_current_user!(_viuser)
    render json: ViuserView.new(_viuser, true)
  end

  struct PriviForm
    include JSON::Serializable

    getter privi : Int32
    getter tspan : Int32
  end

  @[AC::Route::PUT("/upgrade-privi", body: :form)]
  def upgrade_privi(form : PriviForm)
    _viuser.upgrade!(form.privi, form.tspan)

    spawn do
      CtrlUtil.log_user_action("upgrade-privi", form, _uname)

      Dir.mkdir_p("var/chaps/infos/@#{_uname}")
      Dir.mkdir_p("var/texts/rzips/@#{_uname}")
    end

    save_current_user!(_viuser)
    render json: ViuserView.new(_viuser, true)
  rescue err
    render :forbidden, "Bạn chưa đủ số vcoin tối thiểu để tăng quyền hạn!"
  end

  ##################

  record ConfigForm, wtheme : String = "light" do
    include JSON::Serializable
  end

  @[AC::Route::PUT("/config", body: :form)]
  def update_config(form : ConfigForm)
    guard_privi 0, "thay đổi giao diện"

    _viuser.update!({wtheme: form.wtheme})
    render text: "ok"
  end

  struct PasswdForm
    include JSON::Serializable

    getter oldpw : String
    getter newpw : String

    def after_initialize
      @oldpw = @oldpw.strip
      @newpw = @newpw.strip
    end

    def validate!(user : Viuser)
      raise BadRequest.new "Mật khẩu mới quá ngắn" if @newpw.size < 8
      raise BadRequest.new "Mật khẩu cũ không đúng" unless user.authentic?(@oldpw)
    end
  end

  @[AC::Route::PUT("/passwd", body: :form)]
  def update_passwd(form : PasswdForm)
    guard_privi 0, "đổi mật khẩu"

    form.validate!(_viuser)
    _viuser.tap(&.passwd = form.newpw).save!

    spawn do
      body = {email: _viuser.email, cpass: _viuser.cpass}
      CtrlUtil.log_user_action("change-pass", body, _viuser.uname)
    end

    render :accepted, text: "Đổi mật khẩu thành công"
  rescue err
    raise BadRequest.new(err.message)
  end
end
