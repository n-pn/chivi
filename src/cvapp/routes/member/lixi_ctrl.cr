require "../_ctrl_base"

class CV::LixiCtrl < CV::BaseCtrl
  base "/_db/li-xi"

  @[AC::Route::GET("/tet-2024")]
  def index(user : String? = nil, sort : String = "-mtime")
    pg_no, limit, offset = _paginate(min: 50, max: 100)

    rolls = get_rolls(limit, offset, user, sort)

    render json: {
      rolls:  rolls,
      pg_no:  pg_no,
      avail:  _privi + 1 - LixiTet24.roll_count(_uname),
      expiry: EXPIRY.to_unix,
    }
  end

  EXPIRY = Time.utc(2024, 2, 10, 7, 0, 0)

  @[AC::Route::PUT("/roll")]
  def roll
    raise BadRequest.new "Đã hết hạn nhận lì xì :(" if Time.utc > EXPIRY
    raise Unauthorized.new "Bạn cần đăng nhập để nhận lì xì!" if self._privi < 0

    rolled = LixiTet24.roll_count(self._uname)
    raise BadRequest.new "Bạn đã hết số lượt nhận lì xì!" if self._privi < rolled

    vcoin = Random.rand(1..20)
    LixiTet24.new(vu_id: self.vu_id, uname: self._uname, vcoin: vcoin).create!

    _viuser.vcoin += vcoin
    _viuser.save!

    spawn do
      MailUtil.send(to: _viuser.email, name: _viuser.uname) do |mail|
        mail.subject "Chivi: Bạn nhận được #{roll.vcoin} vcoin"

        mail.message_html <<-HTML
          <h3>Thông báo từ Chivi:</h3>
          <p>Bạn nhận được: <strong>#{roll.vcoin}</strong> vcoin từ <strong>Hệ thống</strong>.</p>
          <p>Chú thích của người tặng: Lì xì tết Quý Mão 2024</p>
        HTML
      end
    end

    render json: {
      roll:  roll,
      rolls: get_rolls(10, 0, nil, "-mtime"),
      avail: _privi + 1 - LixiTet24.roll_count(_uname),
    }
  rescue err
    render 400, text: err.message
  end

  private def get_rolls(limit : Int32, offset : Int32, user : String?, sort : String)
    LixiTet24.repo.open_db do |db|
      args = [] of DB::Any

      query = String.build do |sql|
        sql << "select * from rolls"

        if user
          args << user
          sql << " where uname = ?"
        end

        case sort
        when "-mtime" then sql << " order by id desc"
        when "-vcoin" then sql << " order by vcoin desc"
        end

        sql << " limit ? offset ?"
        args << limit << offset
      end

      db.query_all query, args: args, as: LixiTet24
    end
  end
end
