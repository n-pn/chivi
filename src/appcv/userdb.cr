require "./lookup"
require "./models/user_info"

module UserDB
  extend self

  DIR    = File.join("var", "appcv", "members")
  ID_DIR = File.join(DIR, "indexes")
  SR_DIR = File.join(DIR, "serials")

  FileUtils.mkdir_p(ID_DIR)
  FileUtils.mkdir_p(SR_DIR)

  class_getter emails : LabelMap { LabelMap.load("#{ID_DIR}/emails.txt") }
  class_getter unames : LabelMap { LabelMap.load("#{ID_DIR}/unames.txt") }

  def find_by_mail(email : String)
    return unless uslug = emails.fetch(email.downcase)
    UserInfo.get!(uslug)
  end

  def find_by_uname(uname : String)
    return unless uslug = unames.fetch(uname.downcase)
    UserInfo.get!(uslug)
  end

  def create(email : String, uname : String, upass = "chivi.xyz", group = "guest", power = 1)
    raise "email existed" if emails.has_key?(email)
    raise "username existed" if unames.has_key?(uname)

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
    emails.upsert!(info.email.downcase, info.uslug)
    unames.upsert!(info.uname.downcase, info.uslug)
  end

  UBIDS = {} of String => LabelMap

  def ubids(uslug : String)
    UBIDS[uslug] ||= LabelMap.load(File.join(SR_DIR, "#{uslug}.txt"))
  end

  # tags: reading, finished, onhold, dropped

  def add_book_tag(uslug : String, ubid : String, tag : String)
    ubids(uslug).upsert!(ubid, tag)
  end

  def remove_book_tag(uslug : String, ubid : String)
    ubids(uslug).delete!(ubid)
  end

  def tagged_books(uslug : String)
    ubids(uslug).data
  end

  def get_book_tag(uslug : String, ubid : String)
    ubids(uslug).fetch(ubid)
  end
end
