@[Flags]
enum AI::MtFlag
  Hidden
  Frozen
end

class AI::MtTerm
  getter vstr : String
  getter flag : MtFlag
  getter _dic : Int32

  def initialize(@vstr, @flag = MtFlag::None, @_dic = 0)
  end

  DEG2 = new(vstr: "của")
end
