require "./lookup"
require "./userdb/*"

module UserDB
  extend self

  class_getter user_mails : LabelMap { LabelMap.read("var/userdb/mails.txt") }
  class_getter user_names : LabelMap { LabelMap.read("var/userdb/names.txt") }

  def find_by_mail(email : String)
    return unless uslug = user_mails.fetch(email.downcase)
    UserInfo.get!(uslug)
  end

  def find_by_uname(uname : String)
    return unless uslug = user_names.fetch(uname.downcase)
    UserInfo.get!(uslug)
  end

  def create(email : String, uname : String, upass = "chivi.xyz", group = "guest", power = 1)
    raise "email existed" if user_mails.has_key?(email)
    raise "username existed" if user_names.has_key?(uname)

    user = UserInfo.new(email, uname, upass)
    user.group = group
    user.power = power

    upsert_indexes(user)
    user.tap(&.save!)
  end

  def authenticate(email : String, upass : String)
    raise "user does not exists" unless user = find_by_mail(email)
    raise "password does not match" unless user.match_pass?(upass)

    user
  end

  def upsert_indexes(info : UserInfo)
    user_mails.upsert!(info.email.downcase, info.uslug)
    user_names.upsert!(info.uname.downcase, info.uslug)
  end
end
