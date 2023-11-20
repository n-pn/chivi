require "../_ctrl_base"

class CV::UsercpCtrl < CV::BaseCtrl
  base "/_db/_self"

  @[AC::Route::GET("/")]
  def profile
    _viuser.check_privi!(persist: true)
    response.headers["Cache-Control"] = "private, max-age=5, stale-while-revalidate"

    save_current_user!(_viuser)
    render json: ViuserView.new(_viuser, true)
  end

  @[AC::Route::GET("/notifs")]
  def notifs
    guard_privi 0, "xem thông báo cá nhân"

    pg_no, limit, offset = _paginate(min: 10, max: 100)
    notifs = Unotif.user_notifs(_vu_id, limit: limit, offset: offset)

    total = Unotif.count_by_user(_vu_id)
    spawn Unotif.mark_as_read(ids: notifs.map(&.id!))

    render json: {
      notifs: UnotifView.as_list(notifs),

      pgidx: pg_no,
      total: total,
      pgmax: _pgidx(total, limit),
    }
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
      raise BadRequest.new "Mật khẩu mới quá ngắn!" if @newpw.size < 8
      raise BadRequest.new "Mật khẩu cũ không chính xác!" unless user.authentic?(@oldpw)
    end
  end

  @[AC::Route::PUT("/passwd", body: :form)]
  def update_passwd(form : PasswdForm)
    guard_privi 0, "đổi mật khẩu"

    form.validate!(_viuser)
    _viuser.tap(&.passwd = form.newpw).save!

    data = {email: _viuser.email, cpass: _viuser.cpass}
    _log_action("ug-passwd", data)

    render :accepted, text: "Đổi mật khẩu thành công"
  rescue err
    raise BadRequest.new(err.message)
  end
end
