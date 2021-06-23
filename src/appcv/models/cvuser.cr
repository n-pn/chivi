require "crypto/bcrypt/password"

class CV::Cvuser < Granite::Base
  connection pg
  table cvusers

  column id : Int64, primary: true
  timestamps

  column uname : String
  column email : String

  column cpass : String  # encrypted password
  getter upass : String? # virtual field

  # user group and privilege:
  # - admin: 4 // granted all access
  # - vip_2: 3 // granted all premium features
  # - vip_1: 2 // freely reading all content
  # - vip_0: 1 // once a vip, still retain some privilege
  # - leech: 0  // leecher has restristed access
  # - banned: -1 // banned user is treated similar to unregisted user
  column privi : Int32 = 1

  # reserve for future, can be treated as currency
  # rewarded for being a donor or has great contribution
  column karma : Int32 = 0

  # miscellaneous preferences
  # column prefs : Prefs

  validate :email, "is required", ->(cvuser : Cvuser) do
    (email = cvuser.email) ? !email.empty? : false
  end

  # validate :email, "already in use", ->(cvuser : Cvuser) do
  #   existing = Cvuser.find_by(email: cvuser.email)
  #   !existing || existing.id == cvuser.id
  # end

  validate :uname, "is required", ->(cvuser : Cvuser) do
    (uname = cvuser.uname) ? !uname.empty? : false
  end

  # validate :uname, "already in use", ->(cvuser : Cvuser) do
  #   existing = Cvuser.find_by(uname: cvuser.uname)
  #   !existing || existing.id == cvuser.id
  # end

  validate :uname, "is too short", ->(cvuser : Cvuser) do
    if uname = cvuser.uname
      uname.size >= 5
    else
      false
    end
  end

  validate :cpass, "is too short", ->(cvuser : Cvuser) do
    if _pass = cvuser.upass
      _pass.size >= 8
    else
      true
    end
  end

  def upass=(upass : String)
    self.cpass = Crypto::Bcrypt::Password.create(upass, cost: 10).to_s
    @upass = upass
  end

  def authentic?(upass : String)
    Bcrypt::Password.new(@cpass || "").verify(upass)
  end
end
