require "../../appcv/g_vuser"
require "../../_util/cjwt_util"

class CurrentUser
  CACHE = {} of String => self

  def self.from_user_token(token : String)
    CACHE[token] ||= begin
      id, uname, privi = CjwtUtil.decode_user_token(token)
      new(id, uname, privi)
    end
  end

  def self.from_sess_uname(uname : String)
    user = CV::Viuser.load!(uname)
    new(user.id, user.uname, user.privi)
  end

  def self.guest
    new(0, "Khách", -1)
  end

  def self.delete(token : String)
    CACHE.delete(token)
  end

  getter id : Int32, uname : String, privi : Int32

  def initialize(@id, @uname, @privi)
  end

  enum Action
    Level0 = 0
    Level1 = 1
    Level2 = 2
    Level3 = 3
    Level4 = 4
    Level5 = 5

    CreatePost = 0
    UpdatePost = 0
    DeletePost = 0

    MarkPost = 0
  end

  def can?(action : Action = :level0)
    @privi >= action.value
  end

  def can?(owner_id : Int32 | Int64, action : Action = :level0)
    @privi >= 4 || @id == owner_id && @privi >= action.value
  end
end
