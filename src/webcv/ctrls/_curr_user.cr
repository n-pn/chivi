require "../../appcv/member/vi_user"

class CV::Viuser
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
