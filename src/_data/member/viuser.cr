require "crypto/bcrypt/password"
require "../../_util/ram_cache"
require "../_base"
require "./uprivi"

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

  column level : Int16 = 0

  column privi : Int32 = -1
  column p_exp : Int64 = 0

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

  def spend_vcoin!(value : Float64 | Int32)
    query = "update viusers set vcoin = vcoin - $1 where vcoin >= $1 and id = $2 returning vcoin"
    return nil unless vcoin = PGDB.query_one query, value, self.id, as: Int32
    @vcoin = vcoin
  end

  def check_privi!(persist : Bool = true)
    return if !self.privi.in?(0..3) || self.p_exp > Time.utc.to_unix

    uprivi = Uprivi.load!(self.id)
    uprivi.fix_privi!(persist: true)

    self.fix_privi!(uprivi, persist: persist)
  end

  def fix_privi!(uprivi : Uprivi, persist : Bool = false)
    self.privi = uprivi.p_now
    self.p_exp = uprivi.p_exp
    self.save! if persist
  end

  ##############################################

  def self.preload(ids : Enumerable(Int32))
    ids.empty? ? [] of self : self.query.where { id.in? ids.to_a }
  end

  def self.create!(email : String, uname : String, upass : String, privi : Int32 = -1) : self
    raise "Địa chỉ hòm thư quá ngắn" if email.size < 3
    raise "Địa chỉ hòm thư không hợp lệ" if email !~ /@/
    raise "Tên người dùng quá ngắn (cần ít nhất 5 ký tự)" if uname.size < 5
    raise "Tên người dùng không hợp lệ" unless uname =~ /^[\p{L}\p{N}\s_]+$/
    raise "Mật khẩu quá ngắn (cần ít nhất 7 ký tự)" if upass.size < 7

    begin
      user = new({email: email, uname: uname, privi: privi})
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

  def self.load!(id : Int32)
    find!({id: id})
  end

  def self.load!(dname : String) : self
    find!({uname: dname})
  end

  def self.load_many(unames : Array(String))
    query.where("uname IN ?", unames).to_a
  end

  def self.find_any(name_or_email : String)
    query.where("uname = ? OR email = ?", name_or_email, name_or_email).first
  end

  def self.preload(ids : Array(Int32))
    ids.empty? ? [] of self : query.where("id = any(?)", ids)
  end

  def self.get_uname(id : Int32)
    PGDB.query_one("select uname from viusers where id = $1 limit 1", id, as: String)
  end

  def self.get_id(uname : String)
    PGDB.query_one("select id from viusers where uname = $1 limit 1", uname, as: Int32)
  end

  class_getter system : self { self.load!(-1) }
end
