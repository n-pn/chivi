# require "./mt_term"
# require "./shared/*"

# class MT::MtDict
#   getter data = {} of String => Hash(Int8, MtTerm)

#   getter name : String
#   getter type : MtDtyp

#   delegate size, to: @data

#   def initialize(@name : String, @type : MtDtyp = :primary)
#   end

#   @[AlwaysInline]
#   def get?(zstr : String, epos : MtEpos)
#     @data[zstr]?.try(&.[epos.value]?)
#   end

#   @[AlwaysInline]
#   def any?(zstr : String)
#     return unless entry = @data[zstr]?
#     entry.fetch(0_i8) { entry.first_value? }.try(&.as_temp)
#   end

#   ####

#   @[AlwaysInline]
#   def add(zstr : String, epos : MtEpos, vstr : String, attr : MtAttr, lock = 0_i8) : MtTerm
#     dnum = MtDnum.from(dtype: @type, plock: lock)
#     add(zstr: zstr, epos: epos, term: MtTerm.new(vstr, attr: attr, dnum: dnum))
#   end

#   @[AlwaysInline]
#   def add(zstr : String, cpos : String, term : MtTerm) : MtTerm
#     add(zstr: zstr, epos: MtEpos.parse(cpos), term: term)
#   end

#   def add(zstr : String, epos : MtEpos, term : MtTerm) : MtTerm
#     entry = @data[zstr] ||= {} of Int8 => MtTerm
#     entry[epos.value] = term
#   end

#   def del(zstr : String, epos : MtEpos)
#     @data[zstr]?.try(&.delete(epos.value))
#   end

#   def load_tsv!(name : String = @name)
#     db_path = ViTerm.db_path(name, "tsv")
#     return self unless File.file?(db_path)

#     File.each_line(db_path) do |line|
#       cols = line.split('\t')
#       next if cols.size < 2

#       zstr = cols[0]
#       epos = MtEpos.parse?(cols[1]) || MtEpos::X

#       vstr = cols[2]? || ""
#       attr = MtAttr.parse_list(cols[3]?)

#       if vstr.empty? && !attr.hide?
#         self.del(zstr: zstr, epos: epos)
#       else
#         lock = cols[6]?.try(&.to_i8?) || 1_i8
#         self.add(zstr: zstr, epos: epos, vstr: vstr, attr: attr, lock: lock)
#       end
#     end

#     self
#   end

#   def load_db3!(name : String = @name)
#     ViTerm.db(name).open_ro do |db|
#       query = "select zstr, ipos, vstr, iatt from #{ViTerm.schema.table}"

#       db.query_each(query) do |rs|
#         zstr, ipos, vstr, iatt = rs.read(String, Int32, String, Int32)

#         epos = MtEpos.new(ipos.to_i8)

#         # TODO: rebuild iattr enum
#         attr = MtAttr.new(iatt)

#         self.add(zstr, epos: epos, vstr: vstr, attr: attr)
#       end
#     end

#     self
#   rescue ex
#     self
#   end

#   ###

#   # class_getter special : self { new("special", :essence).load_tsv! }
#   class_getter regular : self { new("regular", :regular).load_db3!.load_tsv! }
#   class_getter suggest : self { new("suggest", :hintreg).load_db3! }

#   # @@expire = {} of String => Time
#   ENTRIES = {} of String => self

#   def self.load(name : String, dtyp : MtDtyp = :primary)
#     # @@expire[name] = Time.utc + 10.minutes
#     ENTRIES[name] ||= new(name, dtyp).load_db3!.load_tsv!
#   end

#   def self.get?(name : String)
#     name == "regular" ? @@regular : ENTRIES[name]?
#   end
# end
