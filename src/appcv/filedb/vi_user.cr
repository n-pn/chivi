require "file_utils"
require "crypto/bcrypt/password"

require "../../tsvfs/*"

module CV::ViUser
  extend self

  DIR = "_db/vi_users"
  ::FileUtils.mkdir_p(DIR)

  class_getter _index : ValueMap { ValueMap.new "#{DIR}/_index.tsv" }

  class_getter emails : TokenMap { TokenMap.new "#{DIR}/emails.tsv" }
  class_getter passwd : ValueMap { ValueMap.new "#{DIR}/passwd.tsv" }

  class_getter ugroup : ValueMap { ValueMap.new "#{DIR}/ugroup.tsv" }
  class_getter upower : ValueMap { ValueMap.new "#{DIR}/upower.tsv" }

  class_getter wtheme : ValueMap { ValueMap.new "#{DIR}/wtheme.tsv" }
  class_getter tlmode : ValueMap { ValueMap.new "#{DIR}/tlmode.tsv" }

  class_getter _ctime : ValueMap { ValueMap.new "#{DIR}/_ctime.tsv" }

  def set_uname(dname : String) : String?
    uname = dname.downcase
    uname if _index.set!(uname, dname)
  end

  def set_email(uname : String, email : String) : Nil
    emails.set!(uname, email.downcase)
  end

  def set_cpass(uname : String, upass : String) : Nil
    cpass = Crypto::Bcrypt::Password.create(upass, cost: 10).to_s
    passwd.set!(uname, cpass)
  end

  def set_privi(uname : String, power : Int32)
    upower.set!(uname, power)
  end

  def get_privi(uname : String)
    uname == "khách" ? -1 : upower.ival(uname)
  end

  def get_wtheme(uname : String)
    uname == "khách" ? "light" : wtheme.fval(uname) || "light"
  end

  def get_tlmode(uname : String)
    tlmode.ival(uname) || 1
  end

  def save!(clean : Bool = false)
    @@_index.try(&.save!(clean: clean))

    @@emails.try(&.save!(clean: clean))
    @@passwd.try(&.save!(clean: clean))

    @@ugroup.try(&.save!(clean: clean))
    @@upower.try(&.save!(clean: clean))

    @@wtheme.try(&.save!(clean: clean))
    @@tlmode.try(&.save!(clean: clean))

    @@_ctime.try(&.save!(clean: clean))
  end

  def insert!(dname : String, email : String, upass : String, power = 0) : Nil
    raise "Tên người dùng đã được sử dụng" if dname_exists?(dname)
    raise "Địa chỉ hòm thư đã được sử dụng" if uname = get_uname_by_email(email)
    raise "Lỗi không biết, xin liên hệ ban quản trị" unless uname = set_uname(dname)

    set_email(uname, email)
    set_cpass(uname, upass)
    set_privi(uname, power) if power > 0

    _ctime.set!(uname, Time.utc.to_unix)
    save!(clean: false)
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
