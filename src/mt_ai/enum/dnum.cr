enum MT::MtDnum : Int8
  # Unkn = 0 # reserved
  # Main = 1 # book dict/priv dict/fixture dict that override regular terms
  # Core = 2 # glossaries shared for all books/projects
  # Hintpri = 3 # cpos type "X" in primary dict
  # Hintreg = 4 # cpos type "X" in regular dict
  # Autogen = 5 # entries auto translated by system
  # Fixture = 6 # redefined by translation machine

  # for plock == 0
  Unkn_0    = 0
  Main_0    = 1
  Core_0    = 2
  Hintpri_0 = 3
  Hintreg_0 = 4
  Autogen_0 = 5
  Fixture_0 = 6

  # for plock == 1
  Unkn_1    = 10
  Main_1    = 11
  Core_1    = 12
  Hintpri_1 = 13
  Hintreg_1 = 14
  Autogen_1 = 15
  Fixture_1 = 16

  def on_primary_dict?
    self.to_i8 % 10 % 2 == 1
  end

  @[AlwaysInline]
  def self.from(d_id : Int32, plock : Int16 = 0_i16)
    dtype = d_id % 10 < 4 ? 2_i8 : 1_i8
    new(plock.to_i8 &* 10_i8 &+ dtype)
  end
end
