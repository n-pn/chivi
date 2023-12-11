require "./dict_kind"

enum MT::DictEnum : Int8
  # Unknown = 0 # reserved
  # Primary = 1 # book dict/priv dict/fixture dict that override regular terms
  # Regular = 2 # glossaries shared for all books/projects
  # Hintpri = 3 # cpos type "X" in primary dict
  # Hintreg = 4 # cpos type "X" in regular dict
  # Autogen = 5 # entries auto translated by system
  # Fixture = 6 # redefined by translation machine

  # for plock == 0
  Unknown_0 = 0
  Primary_0 = 1
  Regular_0 = 2
  Hintpri_0 = 3
  Hintreg_0 = 4
  Autogen_0 = 5
  Fixture_0 = 6

  # for plock == 1
  Unknown_1 = 10
  Primary_1 = 11
  Regular_1 = 12
  Hintpri_1 = 13
  Hintreg_1 = 14
  Autogen_1 = 15
  Fixture_1 = 16

  # for plock == 2
  Unknown_2 = 20
  Primary_2 = 21
  Regular_2 = 22
  Hintpri_2 = 23
  Hintreg_2 = 24
  Autogen_2 = 25
  Fixture_2 = 26

  def on_primary_dict?
    self.to_i8 % 10 % 2 == 1
  end

  @[AlwaysInline]
  def self.from(d_id : Int32, plock : Int16)
    dtype = d_id % 10 < 4 ? 2_i8 : 1_i8
    new(plock.to_i8 &* 10_i8 &+ dtype)
  end

  def self.from_rs(rs : ::DB::ResultSet)
    new(rs.read(Int32).to_i8)
  end

  def self.to_db(epos : self)
    epos.to_i
  end
end
