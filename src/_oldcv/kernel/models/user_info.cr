require "file_utils"
require "crypto/bcrypt/password"

require "../../_utils/json_data"
require "../../_utils/uuid_util"

class Oldcv::UserInfo
  include JsonData

  property email = ""
  property uslug = ""
  property uname = ""
  property cpass = ""

  # groups: 'admin', 'angel', 'donor', 'guest', 'extra'
  # powers: 4, 3, 2, 1, 0

  property group = "guest"
  property power = 1
  property karma = 0

  property book_count = 0
  property crit_count = 0
  property post_count = 0

  def initialize(email : String, uname : String, upass = "chivi.xyz")
    set_email(email)
    set_uname(uname)
    set_cpass(upass)
  end

  def set_email(email : String)
    @email = email.strip
    @uslug = UuidUtil.digest32(@email.downcase)
  end

  def set_uname(uname : String)
    @uname = uname.strip
  end

  def set_cpass(upass : String)
    @cpass = Crypto::Bcrypt::Password.create(upass, cost: 10).to_s
  end

  def match_pass?(upass : String)
    Crypto::Bcrypt::Password.new(@cpass).verify(upass)
  end

  # json serialization
  def to_s
    String.build { |io| to_s(io) }
  end

  # :ditto:
  def to_s(io : IO)
    to_json(io)
  end

  def save!(file : String = UserInfo.path_for(@uslug))
    color = changed? ? :yellow : :cyan
    puts "- <user_info> [#{file.colorize(color)}] saved \
            (changes: #{@changes.colorize(color)})."

    @changes = 0
    File.write(file, self)
  end

  # class methods
  DIR = "_db/_oldcv/members"
  FileUtils.mkdir_p(DIR)

  def self.path_for(uslug : String)
    File.join(DIR, "#{uslug}.json")
  end

  def self.existed?(uslug : String)
    File.existed?(path_for(uslug))
  end

  def self.read!(file : String)
    from_json(File.read(file))
  end

  def self.read(file : String)
    read!(file) if File.exists?(file)
  rescue err
    puts "- <user_info> error parsing file [#{file}], err: #{err}".colorize.red
    File.delete(file)
  end

  def self.get!(uslug : String)
    read!(path_for(uslug))
  end

  def self.get(uslug : String)
    read(path_for(uslug))
  end

  CACHE = {} of String => UserInfo

  # load with caching
  def self.preload!(name : String) : UserInfo
    CACHE[name] ||= load!(name)
  end

  def self.cache_user(user : UserInfo)
    CACHE[user.uname] = user
  end
end

# user = UserInfo.new("admin@chivi.xyz")
# puts user

# puts user.match_pass?("chivi.xyz")
