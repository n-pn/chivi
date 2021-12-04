require "crypto/bcrypt/password"

class CV::Cvuser
  include Clear::Model

  self.table = "cvusers"
  primary_key

  has_many ubmemos : Ubmemo, foreign_key: "cvuser_id"
  has_many cvbooks : Cvbook, through: "ubmemos"

  column uname : String
  column email : String

  column cpass : String
  getter upass : String? # virtual password field

  # reserve for future, can be treated as currency
  # rewarded for being a donor or has great contribution
  column karma : Int32 = 0

  # user group and privilege:
  # - admin: 4 // granted all access
  # - vip_2: 3 // granted all premium features
  # - vip_1: 2 // freely reading all content
  # - vip_0: 1 // once a vip, still retain some privilege
  # - leech: 0  // leecher has restristed access
  # - banned: -1 // banned user is treated similar to unregisted user
  column privi : Int32 = 0

  column privi_until : Time? # when the prmium period terminated

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

  DUMMY_PASS = Crypto::Bcrypt::Password.create("chivi123", cost: 10)

  CACHED = RamCache(String, self).new

  def self.load!(dname : String) : self
    CACHED.get(dname) do
      find({uname: dname}) || begin
        raise "User not found!" unless dname == "Khách"
        new({
          uname:  dname,
          email:  "guest@gmail.com",
          cpass:  "xxxxxxxxx",
          privi:  -1,
          wtheme: "light",
        })
      end
    end
  end

  def self.validate(email : String, upass : String)
    if user = find({email: email})
      user.authentic?(upass) ? user : nil
    else
      DUMMY_PASS.verify(upass) # prevent timing attack
      nil
    end
  end
end
