enum MT::MtDnum : Int8
  Unkn0 = 0 # reserved
  User0 = 1 # unique for each user
  Main0 = 2 # book dict/priv dict/fixture dict that override regular terms
  Core0 = 3 # regular dict
  Base0 = 4 # essence dict
  Auto0 = 5 # entries auto translated by system
  Root0 = 6 # redefined by translation machine

  # plock = 1
  Unkn1 = 10
  User1 = 11
  Main1 = 12
  Core1 = 13
  Base1 = 14
  Auto1 = 15
  Root1 = 16

  # plock = 2
  Unkn2 = 20
  User2 = 21
  Main2 = 22
  Core2 = 23
  Base2 = 24
  Auto2 = 25
  Root2 = 26

  def on_primary_dict?
    self.to_i8 % 10 % 2 == 1
  end

  @[AlwaysInline]
  def self.from(d_id : Int32, plock : Int16 = 0_i16)
    dtype = d_id % 10 < 4 ? 2_i8 : 1_i8
    new(plock.to_i8 &* 10_i8 &+ dtype)
  end

  def self.init(kind : self, plock : Int16 = 2_i16)
    kind.value &+ plock &* 10_i8
  end
end
