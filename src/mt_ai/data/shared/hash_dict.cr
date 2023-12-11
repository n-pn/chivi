require "./mt_term"
require "./mt_epos"

class MT::HashDict
  getter hash = {} of String => Hash(MtEpos, MtTerm)

  def initialize(@d_id : Int32)
  end

  # @[AlwaysInline]
  # def add(zstr : String, epos : MtEpos, vstr : String, attr : MtAttr,
  #         prio = 2_i16, posr = 2_i16,
  #         plock = 0_i16) : MtTerm
  #   term = MtTerm.new(
  #     vstr: vstr,
  #     attr: attr,
  #     dnum: DictEnum.from(@d_id, plock),
  #     prio: MtTerm.calc_prio(zstr.size, segr, posr),
  #   )

  #   add(zstr: zstr, epos: epos, term: term)
  # end

  # @[AlwaysInline]
  # def add(zstr : String, cpos : String, term : MtTerm) : MtTerm
  #   add(zstr: zstr, epos: MtEpos.parse(cpos), term: term)
  # end

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
