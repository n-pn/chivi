enum MT::MtDnum : Int8
  UserTmp  = 0 # unique for each user (match ptag)
  UserTmpX = 1 # pick first definition (ptag do not match)

  MainTmp  = 2 # book dict/priv dict/fixture dict that override regular terms
  MainTmpX = 3 # (ptag do not match)

  BaseTmp  = 4 # regular dict (ptag match)
  BaseTmpX = 5 # regular dict (ptag dont match)

  AutoTmp = 6 # entries auto translated

  # verified

  UserFix  = 10
  UserVfdX = 11

  MainFix  = 12
  MainVfdX = 13

  BaseFix  = 14
  BaseVfdX = 15

  AutoFix = 16 # words changed by pair

  def as_any
    self.value % 2 == 0 ? MtDnum.new(self.value + 1) : self
  end

  @[AlwaysInline]
  def self.from(d_id : Int32, plock : Int16 = 0_i16)
    base = plock > 0 ? 10_i8 : 0_i8

    case MtDtyp.from_value(d_id % 10)
    when .global? then new(BaseTmp.value &+ base)
    when .system? then new(AutoTmp.value &+ base)
    when .userqt? then new(UserTmp.value &+ base)
    else               new(MainTmp.value &+ base)
    end
  end

  def self.init(kind : self, plock : Int16 = 2_i16)
    kind.value &+ plock &* 10_i8
  end
end
