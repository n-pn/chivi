require "crypto/bcrypt/password"

class CV::Cvuser
  include Clear::Model

  self.table = "cvusers"
  primary_key

  column uname : String
  column email : String

  column cpass : String
  getter upass : String? # virtual password field

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
    Crypto::Bcrypt::Password.new(cpass).verify(upass)
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

  def self.load!(id : Int64)
    CACHE_INT.get(id) { find!({id: id}) }
  end

  CACHED = {} of String => self

  def self.load!(dname : String) : self
    CACHE_STR.get(dname.downcase) do
      user = find!({uname: dname})
      user.tap { |x| CACHE_INT.set(x.id, x) }
    end
  end

  DUMMY_PASS = Crypto::Bcrypt::Password.create("chivi123", cost: 10)

  def self.validate(email : String, upass : String)
    if user = find({email: email})
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
