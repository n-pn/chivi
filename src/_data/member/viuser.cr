require "crypto/bcrypt/password"
require "../../_util/ram_cache"
require "../_base"

class CV::Viuser
  include Clear::Model

  self.table = "viusers"
  primary_key type: :serial

  column uname : String
  column email : String

  column cpass : String

  column pwtemp : String = ""
  column pwtemp_until : Int64 = 0

  # user group and privilege:
  # - admin: 4 // granted all access
  # - vip_3: 3 // granted all premium features
  # - vip_2: 2 // freely reading all content
  # - vip_1: 1 // limited access
  # - basic: 0 // restristed access
  # - banned: -1 // banned user is treated similar to unregisted user

  column privi : Int32 = 0
  column privi_until : Array(Int64) = [0_i64, 0_i64, 0_i64]

  column vcoin : Float64 = 0

  column last_loggedin_at : Time = Time.utc
  column reply_checked_at : Time = Time.utc
  column notif_checked_at : Time = Time.utc

  # TODO: mapping miscellaneous preferences
  column wtheme : String = "light"

  timestamps

  def passwd=(upass : String)
    self.cpass = Crypto::Bcrypt::Password.create(upass, cost: 10).to_s
  end

  def authentic?(upass : String)
    Crypto::Bcrypt::Password.new(cpass).verify(upass) || pwtemp?(upass)
  end

  def point_limit
    privi < 0 ? 0 : (self.vcoin * 1000).round.to_i &+ (2 ** self.privi) * 100_000
  end

  def pwtemp?(upass : String)
    self.pwtemp == upass && self.pwtemp_until >= Time.utc.to_unix
  end

  PWTEMP_TSPAN = 5.minutes

  def set_pwtemp!
    self.pwtemp = HashUtil.rand_str(8)
    self.pwtemp_until = (Time.utc + PWTEMP_TSPAN).to_unix

    self.save!
  end

  PRIVI_DAYS = {14, 30, 60, 90}
  PRIVI_COST = {
    {10, 20, 35, 50},    # privi 1
    {30, 50, 90, 130},   # privi 2
    {50, 100, 175, 250}, # privi 3
  }

  def current_privi_until(privi = self.privi)
    self.privi_until[privi &- 1]? || Time.utc.to_unix &+ 86400 &* 360
  end

  def upgrade_privi!(new_privi : Int32, range : Int32, persist : Bool = true)
    req_vcoin = PRIVI_COST[new_privi &- 1][range]
    raise "Lượng vcoin không đủ!" if req_vcoin > self.vcoin

    self.vcoin -= req_vcoin
    self.privi = new_privi if self.privi < new_privi

    pdays = PRIVI_DAYS[range]
    tspan = pdays &* 86400
    t_now = Time.utc.to_unix

    if new_privi > 0
      extend_privi_until(0, tspan, t_now)
    end

    if new_privi > 1
      extend_privi_until(1, tspan, t_now)
      self.privi_until[0] &+= new_privi == 2 ? tspan // 2 : tspan // 4
    end

    if new_privi > 2
      extend_privi_until(2, tspan, t_now)
      self.privi_until[1] &+= tspan // 2
    end

    self.privi_until_column.dirty! # make clear update this column

    self.save! if persist
    {req_vcoin, pdays}
  end

  private def extend_privi_until(index : Int32, tspan : Int32, t_now = Time.utc.to_unix)
    self.privi_until[index] = t_now if self.privi_until[index] < t_now
    self.privi_until[index] &+= tspan
  end

  def downgrade_privi! : Nil
    t_now = Time.utc.to_unix

    {3, 2, 1}.each do |privi|
      next unless self.privi == privi
      return if t_now <= self.privi_until[privi &- 1]
      self.privi = privi &- 1
    end
  end

  def check_privi! : Nil
    self.downgrade_privi!
    self.last_loggedin_at = Time.utc

    self.save!
    self.cache!
  end

  def cache!
    CACHE_INT.set(self.id, self)
    CACHE_STR.set(self.uname.downcase, self)
  end

  ##############################################

  def self.preload(ids : Enumerable(Int32))
    ids.empty? ? [] of self : self.query.where { id.in? ids.to_a }
  end

  def self.create!(email : String, uname : String, upass : String) : self
    raise "Địa chỉ hòm thư quá ngắn" if email.size < 3
    raise "Địa chỉ hòm thư không hợp lệ" if email !~ /@/
    raise "Tên người dùng quá ngắn (cần ít nhất 5 ký tự)" if uname.size < 5
    raise "Tên người dùng không hợp lệ" unless uname =~ /^[\p{L}\p{N}\s_]+$/
    raise "Mật khẩu quá ngắn (cần ít nhất 7 ký tự)" if upass.size < 7

    begin
      user = new({email: email, uname: uname})
      user.passwd = upass
      user.tap(&.save!)
    rescue err
      case err.message || ""
      when .includes?("uname_key")
        raise "Tên người dùng đã được sử dụng"
      when .includes?("email_key")
        raise "Địa chỉ hòm thư đã được sử dụng"
      else
        raise "Không rõ lỗi, mời thử lại!"
      end
    end
  end

  CACHE_INT = RamCache(Int32, self).new(ttl: 3.minutes)
  CACHE_STR = RamCache(String, self).new(ttl: 3.minutes)

  def self.load!(id : Int32)
    CACHE_INT.get(id) { find!({id: id}) }
  end

  CACHED = {} of String => self

  def self.load!(dname : String) : self
    CACHE_STR.get(dname.downcase) { find!({uname: dname}) }
  end

  def self.load_many(unames : Array(String))
    query.where("uname IN ?", unames).to_a
  end

  def self.find_any(name_or_email : String)
    query.where("uname = ? OR email = ?", name_or_email, name_or_email).first
  end

  def self.glob(user_ids : Array(Int32))
    self.query.where { id.in? user_ids }
  end
end
