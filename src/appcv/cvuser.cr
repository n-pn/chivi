require "crypto/bcrypt/password"

class CV::Cvuser
  include Clear::Model

  self.table = "cvusers"
  primary_key

  column uname : String
  column email : String

  column cpass : String
  getter upass : String? # virtual password field

  column pwtemp : String = ""
  column pwtemp_until : Int64 = 0

  # user group and privilege:
  # - admin: 4 // granted all access
  # - vip_2: 3 // granted all premium features
  # - vip_1: 2 // freely reading all content
  # - vip_0: 1 // once a vip, still retain some privilege
  # - leech: 0  // leecher has restristed access
  # - banned: -1 // banned user is treated similar to unregisted user
  column privi : Int32 = 0
  column privi_1_until : Int64 = 0
  column privi_2_until : Int64 = 0
  column privi_3_until : Int64 = 0

  column vcoin_total : Int32 = 0
  column vcoin_avail : Int32 = 0

  column last_loggedin_at : Time = Time.utc
  column reply_checked_at : Time = Time.utc
  column notif_checked_at : Time = Time.utc

  # TODO: mapping miscellaneous preferences
  column wtheme : String = "light"

  timestamps

  def upass=(upass : String)
    self.cpass = Crypto::Bcrypt::Password.create(upass, cost: 10).to_s
    @upass = upass
  end

  def authentic?(upass : String)
    Crypto::Bcrypt::Password.new(cpass).verify(upass) || pwtemp?(upass)
  end

  PWTEMP_TSPAN = 5.minutes

  def pwtemp?(upass : String)
    self.pwtemp == upass && self.pwtemp_until >= Time.utc.to_unix
  end

  def set_pwtemp!
    self.pwtemp = UkeyUtil.rand_str(8)
    self.pwtemp_until = (Time.utc + PWTEMP_TSPAN).to_unix

    save!
  end

  TSPAN_UNIT = 1.days.total_seconds.to_i
  PRIVI_SPAN = {14, 30, 60, 90}.map(&.* TSPAN_UNIT)
  PRIVI_COST = {
    {0, 0, 0, 0},        # privi 0
    {10, 20, 35, 50},    # privi 1
    {30, 50, 90, 130},   # privi 2
    {50, 100, 175, 250}, # privi 2
  }

  def fix_vcoin(value : Int32)
    self.vcoin_total += value if value > 0
    self.vcoin_avail += value
  end

  def upgrade!(privi : Int32, tspan : Int32) : Tuple(Int64, Int64, Int64)
    vcoin = PRIVI_COST[privi][tspan]
    raise "Not enough vcoin" if vcoin_avail < vcoin

    self.vcoin_avail -= vcoin
    self.privi = privi

    tspan = PRIVI_SPAN[tspan]
    start = Time.utc.to_unix

    if privi == 3
      self.privi_3_until = start if self.privi_3_until < start
      self.privi_3_until += tspan
      self.privi_2_until = self.privi_3_until
      tspan //= 2
      privi = 2
    end

    if privi == 2
      self.privi_2_until = start if self.privi_2_until < start
      self.privi_2_until += tspan
      self.privi_1_until = self.privi_2_until
      tspan //= 2
    end

    self.privi_1_until = start if self.privi_1_until < start
    self.privi_1_until += tspan

    self.save!
    {self.privi_1_until, self.privi_2_until, self.privi_3_until}
  end

  def downgrade_privi! : Nil
    now = Time.utc.to_unix

    if self.privi == 3
      return if now < self.privi_3_until
      self.privi = 2
    end

    if self.privi == 2
      return if now < self.privi_2_until
      self.privi = 1
    end

    if self.privi == 1
      self.privi = 0 if now > self.privi_1_until
    end
  end

  ##############################################

  def self.create!(email : String, uname : String, upass : String) : self
    raise "Địa chỉ hòm thư quá ngắn" if email.size < 3
    raise "Địa chỉ hòm thư không hợp lệ" if email !~ /@/
    raise "Tên người dùng quá ngắn (cần ít nhất 5 ký tự)" if uname.size < 5
    raise "Tên người dùng không hợp lệ" unless uname =~ /^[\p{L}\p{N}\s_]+$/
    raise "Mật khẩu quá ngắn (cần ít nhất 7 ký tự)" if upass.size < 7

    begin
      Cvuser.new({email: email, uname: uname, upass: upass}).tap(&.save!)
    rescue err
      case err.message || ""
      when .includes?("cvusers_uname_key")
        raise "Tên người dùng đã được sử dụng"
      when .includes?("cvusers_email_key")
        raise "Địa chỉ hòm thư đã được sử dụng"
      else
        raise "Không rõ lỗi, mời thử lại!"
      end
    end
  end

  CACHE_INT = RamCache(Int64, self).new
  CACHE_STR = RamCache(String, self).new

  def self.find_by_mail(email : String)
    return unless user = find({email: email})

    CACHE_INT.set(user.id, user)
    CACHE_STR.set(user.uname.downcase, user)

    user
  end

  def self.load!(id : Int64)
    CACHE_INT.get(id) { find!({id: id}) }
  end

  CACHED = {} of String => self

  def self.load!(dname : String) : self
    CACHE_STR.get(dname.downcase) do
      user = find!({uname: dname})
      user.downgrade_privi!
      user.last_loggedin_at = Time.utc
      user.save!
      user.tap { |x| CACHE_INT.set(x.id, x) }
    end
  end

  DUMMY_PASS = Crypto::Bcrypt::Password.create("----", cost: 10)

  def self.validate(email : String, upass : String)
    if user = find_by_mail(email)
      user.authentic?(upass) ? user : nil
    else
      DUMMY_PASS.verify(upass) # prevent timing attack
      nil
    end
  end

  def self.load_many(unames : Array(String))
    query.where("uname IN ?", unames).to_a
  end
end
