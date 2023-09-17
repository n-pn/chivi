require "./mt_term"

enum MT::MtDtyp : Int8
  Unknown = 0 # reserved
  Primary = 1 # book dict/priv dict/fixture dict that override regular terms
  Regular = 2 # glossaries shared for all books/projects
  Hintpri = 3 # cpos type "_" in primary dict
  Hintreg = 4 # cpos type "_" in regular dict
  Autogen = 5 # entries auto translated by system
  Fixture = 6 # redefined by translation machine
end

enum MT::MtDnum : Int8
  Unknown_0 = 0 # for plock == 0
  Primary_0 = 1 # for plock == 0
  Regular_0 = 2 # for plock == 0
  Hintpri_0 = 3 # for plock == 0
  Hintreg_0 = 4 # for plock == 0
  Autogen_0 = 5 # for plock == 0
  Fixture_0 = 6 # for plock == 0

  Unknown_1 = 10 # for plock == 1
  Primary_1 = 11 # for plock == 1
  Regular_1 = 12 # for plock == 1
  Hintpri_1 = 13 # for plock == 1
  Hintreg_1 = 14 # for plock == 1
  Autogen_1 = 15 # for plock == 1
  Fixture_1 = 16 # for plock == 1

  Unknown_2 = 20 # for plock == 2
  Primary_2 = 21 # for plock == 2
  Regular_2 = 22 # for plock == 2
  Hintpri_2 = 23 # for plock == 2
  Hintreg_2 = 24 # for plock == 2
  Autogen_2 = 25 # for plock == 2
  Fixture_2 = 26 # for plock == 2

  def on_primary_dict?
    self.to_i8 % 10 % 2 == 1
  end

  @[AlwaysInline]
  def self.from(dtype : Int8, plock : Int8)
    plock &* 10_i8 &+ dtype
  end

  @[AlwaysInline]
  def self.from(dtype : MtDtyp, plock : Int8)
    plock &* 10_i8 &+ dtype.to_i8
  end
end

class MT::MtDict
  getter data = {} of String => Hash(Int8, MtTerm)

  getter name : String
  getter type : MtDtyp

  delegate size, to: @data

  def initialize(@name : String, @type : MtDtyp = :primary)
  end

  @[AlwaysInline]
  def get?(zstr : String, ipos : Int8)
    @data[zstr]?.try(&.[ipos]?)
  end

  @[AlwaysInline]
  def any?(zstr : String)
    return unless entry = @data[zstr]?
    entry.fetch(0_i8) { entry.first_value? }.try(&.as_temp)
  end

  ####

  @[AlwaysInline]
  def add(zstr : String, ipos : Int8, vstr : String, attr : MtAttr, lock = 0_i8) : MtTerm
    dnum = MtDnum.from(dtype: @type, plock: lock)
    add(zstr: zstr, ipos: ipos, term: MtTerm.new(vstr, attr: attr, dnum: dnum))
  end

  @[AlwaysInline]
  def add(zstr : String, cpos : String, term : MtTerm) : MtTerm
    add(zstr: zstr, ipos: MtCpos[cpos], term: term)
  end

  def add(zstr : String, ipos : Int8, term : MtTerm) : MtTerm
    entry = @data[zstr] ||= {} of Int8 => MtTerm
    entry[ipos] = term
  end

  def load_tsv!(name : String = @name)
    db_path = ViTerm.db_path(name, "tsv")
    return self unless File.file?(db_path)

    File.each_line(db_path) do |line|
      cols = line.split('\t')
      next if cols.size < 3

      zstr = cols[0]
      ipos = MtCpos[cols[1]]
      vstr = cols[2]
      attr = MtAttr.parse_list(cols[3]?)
      lock = cols[6]?.try(&.to_i8?) || 1_i8

      add(zstr: zstr, ipos: ipos, vstr: vstr, attr: attr, lock: lock)
    end

    self
  end

  def load_db3!(name : String = @name)
    # ViTerm.db(name).open_ro do |db|
    #   query = "select zstr, icpos, vstr, iattr, plock from #{ViTerm.schema.table}"

    #   db.query_each(query) do |rs|
    #     zstr = rs.read(String)
    #     ipos = rs.read(Int32).unsafe_as(Int8)
    #     vstr = rs.read(String)
    #     attr = MtAttr.new(rs.read(Int32))
    #     lock = rs.read(Int32).unsafe_as(Int8)
    #     add(zstr, ipos: ipos, vstr: vstr, attr: attr, lock: lock)
    #   end
    # end

    ViTerm.db(name).open_ro do |db|
      query = "select zstr, cpos, vstr, attr from #{ViTerm.schema.table}"

      db.query_each(query) do |rs|
        zstr, cpos, vstr, attr = rs.read(String, String, String, String)
        add(zstr, ipos: MtCpos[cpos], vstr: vstr, attr: MtAttr.parse_list(attr))
      end
    end

    self
  rescue ex
    self
  end

  ###

  # class_getter special : self { new("special", :essence).load_tsv! }
  class_getter regular : self { new("regular", :regular).load_db3!.load_tsv! }
  class_getter suggest : self { new("suggest", :hintreg).load_db3! }

  # @@expire = {} of String => Time
  ENTRIES = {} of String => self

  def self.load(name : String, dtyp : MtDtyp = :primary)
    # @@expire[name] = Time.utc + 10.minutes
    ENTRIES[name] ||= new(name, dtyp).load_db3!.load_tsv!
  end

  def self.get?(name : String)
    ENTRIES[name]?
  end
end
