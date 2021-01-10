require "file_utils"
require "crypto/bcrypt/password"
require "./stores/*"

module CV::Viuser
  extend self

  class_getter _index : ValueMap { ValueMap.new(map_path("_index")) }

  class_getter emails : TokenMap { TokenMap.new(map_path("emails")) }
  class_getter passwd : ValueMap { ValueMap.new(map_path("passwd")) }

  class_getter ugroup : ValueMap { ValueMap.new(map_path("ugroup")) }
  class_getter upower : ValueMap { ValueMap.new(map_path("upower")) }

  class_getter create_tz : ValueMap { ValueMap.new(map_path("tz_create")) }

  DIR = "_db/nvdata/viusers"
  ::FileUtils.mkdir_p(DIR)

  def map_path(label : String)
    "#{DIR}/#{label}.tsv"
  end

  def set_uname(dname : String) : String?
    uname = dname.downcase
    uname if _index.add(uname, dname)
  end

  def set_email(uname : String, email : String) : Nil
    emails.add(uname, email.downcase)
  end

  def set_cpass(uname : String, upass : String) : Nil
    cpass = Crypto::Bcrypt::Password.create(upass, cost: 10).to_s
    passwd.add(uname, cpass)
  end

  def set_power(uname : String, power : Int32)
    upower.add(uname, power)
  end

  def save!(mode : Symbol = :full)
    @@_index.try(&.save!(mode: mode))

    @@emails.try(&.save!(mode: mode))
    @@passwd.try(&.save!(mode: mode))

    @@ugroup.try(&.save!(mode: mode))
    @@upower.try(&.save!(mode: mode))

    @@create_tz.try(&.save!(mode: mode))
  end

  def insert!(dname : String, email : String, upass : String, power = 1) : Nil
    raise "username existed" if dname_exists?(dname)
    raise "email existed" if uname = get_uname_by_email(email)

    raise "db corrupted" unless uname = set_uname(dname)
    set_email(uname, email)
    set_cpass(uname, upass)
    set_power(uname, power)

    create_tz.add(uname, Time.utc.to_unix)
  end

  def dname_exists?(dname : String) : Bool
    _index.has_key?(dname.downcase)
  end

  def get_uname_by_email(email : String) : String?
    emails.keys(email.downcase).first?
  end

  def validate(email : String, upass : String) : String?
    return nil unless uname = get_uname_by_email(email)
    return uname if valid_pass?(uname, upass)
  end

  def valid_pass?(uname : String, upass : String) : Bool
    return false unless cpass = passwd.fval(uname)
    Crypto::Bcrypt::Password.new(cpass).verify(upass)
  end
end
