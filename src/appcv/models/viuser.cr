require "crypto/bcrypt/password"

class CV::Viuser < Granite::Base
  connection pg
  table viusers

  column id : Int32, primary: true
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

  validate :email, "is required", ->(viuser : Viuser) do
    (email = viuser.email) ? !email.empty? : false
  end

  # validate :email, "already in use", ->(viuser : Viuser) do
  #   existing = Viuser.find_by(email: viuser.email)
  #   !existing || existing.id == viuser.id
  # end

  validate :uname, "is required", ->(viuser : Viuser) do
    (uname = viuser.uname) ? !uname.empty? : false
  end

  # validate :uname, "already in use", ->(viuser : Viuser) do
  #   existing = Viuser.find_by(uname: viuser.uname)
  #   !existing || existing.id == viuser.id
  # end

  validate :uname, "is too short", ->(viuser : Viuser) do
    if uname = viuser.uname
      uname.size >= 5
    else
      false
    end
  end

  validate :cpass, "is too short", ->(viuser : Viuser) do
    if _pass = viuser.upass
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
