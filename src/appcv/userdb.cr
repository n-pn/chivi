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

  UBIDS = {} of String => TokenMap

  def ubids(uslug : String)
    UBIDS[uslug] ||= TokenMap.read(File.join(SR_DIR, "#{uslug}.txt"))
  end

  # tags: viewed, liked, reading, completed, onhold, dropped

  def add_book_tag(uslug : String, ubid : String, tag : String)
    mapper = ubids(uslug)

    if tags = mapper.vals(ubid)
      return if tags.includes?(tag)
      tags << tag
    else
      tags = [tag]
    end

    mapper.upsert!(ubid, tags)
  end

  def remove_book_tag(uslug : String, ubid : String, tag : String)
    mapper = ubids(uslug)
    return unless tags = mapper.vals(ubid)
    tags.delete(tags) if tags.includes?(tag)
    mapper.upsert!(ubid, tags)
  end

  def update_book_tag(uslug : String, ubid : String, old_tag : String, new_tag : String)
    mapper = ubids(uslug)
    return add_book_tag(uslug, ubid, new_tag) unless tags = mapper.vals(ubid)

    tags.delete(old_tag) if tags.includes?(old_tag)
    tags.push(new_tag) unless tags.includes?(new_tag)

    mapper.upsert!(ubid, tags)
  end

  def list_books(uslug : String, tag : String)
    ubids(uslug).keys(tag)
  end
end
