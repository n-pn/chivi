require "../_ctrl_base"

class CV::LixiCtrl < CV::BaseCtrl
  base "/_db/li-xi"

  @[AC::Route::GET("/tet-2024")]
  def index(user : String? = nil, sort : String = "-mtime")
    pg_no, limit, offset = _paginate(min: 50, max: 100)

    rolls = LixiTet24.get_rolls(limit, offset, user, sort)
    avail = _privi + 1 - LixiTet24.roll_count(_uname)

    render json: {
      rolls:  rolls,
      pg_no:  pg_no,
      avail:  avail,
      expiry: EXPIRY.to_unix,
    }
  end

  EXPIRY = Time.local(2024, 2, 13, 1, 0, 0)

  @[AC::Route::PUT("/roll")]
  def roll
    raise BadRequest.new "Đã hết hạn nhận lì xì :(" if Time.utc > EXPIRY
    raise Unauthorized.new "Bạn cần đăng nhập để nhận lì xì!" if self._privi < 0

    rolled = LixiTet24.roll_count(self._uname)
    raise BadRequest.new "Bạn đã hết số lượt nhận lì xì!" if self._privi < rolled

    vcoin = Random.rand(1..50)
    roll = LixiTet24.new(vu_id: self._vu_id, uname: self._uname, vcoin: vcoin).insert!

    _viuser.vcoin += vcoin
    _viuser.save!

    spawn do
      MailUtil.send(to: _viuser.email, name: _viuser.uname) do |mail|
        mail.subject "Chivi: Bạn nhận được #{vcoin} vcoin"

        mail.message_html <<-HTML
          <h3>Thông báo từ Chivi:</h3>
          <p>Bạn nhận được: <strong>#{vcoin}</strong> vcoin từ <strong>Hệ thống</strong>.</p>
          <p>Chú thích của người tặng: Lì xì tết Giáp Thìn 2024</p>
        HTML
      end
    end

    rolls = LixiTet24.get_rolls(10, 0, nil, "-mtime")
    render json: {
      vcoin: vcoin,
      rolls: rolls,
      avail: self._privi &- rolled,
    }
  rescue err
    render 400, text: err.message
  end
end
