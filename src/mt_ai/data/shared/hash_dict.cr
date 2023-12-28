require "./dict_kind"

require "./mt_term"
require "./mt_epos"
require "../mt_data"

class MT::HashDict
  CACHE_HD = {} of String => self

  class_getter regular : self { load!("regular") }
  class_getter essence : self { load!("essence") }
  class_getter suggest : self { load!("suggest") }
  class_getter nqnt_vi : self { load!("nqnt_vi") }

  def self.load!(dname : String) : self
    CACHE_HD[dname] ||= begin
      hash = new(DictKind.map_id(dname))
      time = Time.measure { hash.load_from_db3! }
      Log.info { "loading #{dname} hash: #{time.total_milliseconds}" }
      hash
    end
  end

  def self.add_term(dname : String, zstr : String, epos : MtEpos, mterm : MtTerm)
    CACHE_HD[dname]?.try(&.add(zstr, epos, mterm))
  end

  def self.delete_term(dname : String, zstr : String, epos : MtEpos)
    CACHE_HD[dname]?.try(&.delete(zstr, epos))
  end

  ###

  getter hash = {} of String => Hash(MtEpos, MtTerm)

  def initialize(@d_id : Int32)
  end

  def load_from_db3!(d_id = @d_id, reset : Bool = false)
    @hash.clear if reset

    MtData.load_db(d_id).open_ro do |db|
      query = "select zstr, epos, vstr, attr, dnum, fpos from mtdata where d_id = $1"
      db.query_each(query, d_id) do |rs|
        zstr = rs.read(String)
        epos = MtEpos.from_value(rs.read(Int32))

        vstr = rs.read(String)
        attr = MtAttr.from_value(rs.read(Int32))
        dnum = DictEnum.from_value(rs.read(Int32))
        fpos = MtEpos.from_value(rs.read(Int32))

        add(zstr, epos, MtTerm.new(vstr: vstr, attr: attr, dnum: dnum, fpos: fpos))
      end
    end
  end

  def add(zstr : String, epos : MtEpos, term : MtTerm) : MtTerm
    list = @hash[zstr] ||= {} of MtEpos => MtTerm
    list[epos] = term
  end

  def get?(zstr : String, cpos : String)
    get?(zstr: zstr, epos: MtEpos.parse(cpos))
  end

  def get?(zstr : String, epos : MtEpos)
    @hash[zstr]?.try(&.[epos]?)
  end

  def any?(zstr : String)
    return unless hash = @hash[zstr]?
    hash.each_value.first
  end

  def delete(zstr : String, epos : MtEpos)
    @hash[zstr]?.try(&.delete(epos))
  end
end
