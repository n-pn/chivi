class CV::Cvuser
  include Clear::Model

  self.table = "cvusers"
  primary_key

  has_many ubmarks : Ubmark, foreign_key: "cvuser_id"
  has_many ubviews : Ubview, foreign_key: "cvuser_id"
  has_many cvbooks : Cvbook, through: "ubmarks"

  column uname : String
  column email : String

  column cpass : Crypto::Bcrypt::Password
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

  # validate_not_blank :email
  # validate_not_blank :uname
  # validate_uniqueness :email
  # validate_uniqueness :uname

  # validate_min_length :uname, 5
  # validate_min_length :upass, 8

  def upass=(upass : String)
    self.cpass = Crypto::Bcrypt::Password.create(upass, cost: 10)
    @upass = upass
  end

  def authentic?(upass : String)
    self.cpass.verify(upass)
  end
end
