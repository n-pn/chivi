require "./_setup"

class CV::Viuser
  include Clear::Model

  primary_key type: serial

  column uname : String # display name
  column email : String # unique email

  column cpass : Crypto::Bcrypt::Password # encrypted password

  # user group and privilege:
  # - admin: 4 // granted all access
  # - vip_2: 3 // granted all premium features
  # - vip_1: 2 // freely reading all content
  # - vip_0: 1 // once a vip, still retain some privilege
  # - leech: 0  // leecher has restristed access
  # - banned: -1 // banned user is treated similar to unregisted user
  column privi : Int32, presence: false

  # reserve for future, can be treated as currency
  # rewarded for being a donor or has great contribution
  column karma : Int32, presence: false # default to 0

  # miscellaneous preferences
  column prefs : JSON::Any, presence: false

  def passwd=(pass : String)
    self.cpass = Crypto::Bcrypt::Password.create(pass, cost: 10)
  end
end
