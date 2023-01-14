require "../../appcv/member/vi_user"

# require "../../_util/cjwt_util"

class CV::Viuser
  # CACHE = {} of String => self

  # def self.from_user_token(token : String)
  #   CACHE[token] ||= begin
  #     id, uname, privi = CjwtUtil.decode_user_token(token)
  #     new(id, uname, privi)
  #   end
  # end

  # def self.from_sess_uname(uname : String)
  #   user = CV::Viuser.load!(uname)
  #   new(user.id, user.uname, user.privi)
  # end

  # def self.guest
  #   new(0, "Khách", -1)
  # end

  # def self.delete(token : String)
  #   CACHE.delete(token)
  # end

  # getter id : Int32, uname : String, privi : Int32

  # def initialize(@id, @uname, @privi)
  # end

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
    self.privi >= action.value
  end

  def can?(owner_id : Int32 | Int64, action : Action = :level0)
    self.privi >= 4 || self.id == owner_id && self.privi >= action.value
  end

  def can?(owner : String, action : Action = :level0)
    self.privi >= 4 || self.uname == owner && self.privi >= action.value
  end
end
