require "crypto/bcrypt/password"

class CV::Cvuser < Granite::Base
  connection pg
  table cvusers

  column id : Int64, primary: true
  timestamps

  has_many :ubmark
  has_many :ubview
  has_many :cvbook, through: :ubmark

  column uname : String
  column email : String

  column cpass : String  # encrypted password
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
  # column prefs : Prefs

  validate_not_blank :email
  validate_not_blank :uname
  validate_uniqueness :email
  validate_uniqueness :uname

  validate_min_length :uname, 5
  validate_min_length :upass, 8

  def upass=(upass : String)
    self.cpass = Crypto::Bcrypt::Password.create(upass, cost: 10).to_s
    @upass = upass
  end

  def authentic?(upass : String)
    Bcrypt::Password.new(@cpass || "").verify(upass)
  end
end
