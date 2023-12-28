require "../_raw/raw_con"
require "./ai_node/*"
require "./mt_core/*"

class MT::AiCore
  CACHE = {} of String => self

  def self.load(pdict : String)
    CACHE[pdict] ||= new(pdict.sub("book", "wn").tr(":/", ""))
  end

  @dicts : {HashDict, HashDict, HashDict, HashDict}

  def initialize(pdict : String)
    @dicts = {
      HashDict.load!(pdict),
      HashDict.regular,
      HashDict.essence,
      HashDict.suggest,
    }
  end

  def translate!(data : RawCon, pre_term : Nil = nil)
    init_node(data, from: 0)
  end

  def translate!(data : RawCon, pre_term : AiTerm)
    pre_orig = pre_term.orig.as(String)
    pre_tran = pre_term.tran.as(String)

    root = init_node(data, from: pre_orig.size)

    case orig = root.orig
    when String
      root.orig = "#{pre_orig}#{orig}"
    when Array
      root.orig.unshift(RawCon.new(pre.epos.to_s, pre_orig))
    end

    case tran = root.tran
    when String
      root.tran = "#{pre_tran}#{tran}"
    else
      root.tran.unshift(pre_term)
    end

    root
  end

  private def init_node(data : RawCon, from : Int32 = 0)
    epos, attr = MtEpos.parse_ctb(data.cpos)
    zstr, body = data.zstr, data.body
    upto = from &+ zstr.size

    if defn = find_defn(zstr, epos, attr, body)
      return AiTerm.new(
        epos: defn.fpos.x? ? epos : defn.fpos,
        attr: defn.attr | attr,
        orig: zstr, tran: defn.vstr,
        dnum: defn.dnum, from: from, upto: upto)
    elsif body.is_a?(String)
      vstr = get_any_defn?(zstr).try(&.vstr) || QtCore.tl_hvword(zstr)

      return AiTerm.new(
        epos: epos, attr: attr, orig: zstr, tran: vstr,
        dnum: :autogen_0, from: from, upto: upto
      )
    end

    tran = body.map { |raw| init_node(raw, from: from).tap { |x| from = x.upto } }

    # TODO: fix tran
    # case
    # when epos.top?
    #   MxNode.new(list, epos, attr: attr, _idx: _idx)
    # when list.size == 1
    #   M1Node.new(list[0], epos, attr: attr, _idx: _idx)
    # when epos.np?
    #   NpNode.new(list, epos, attr: attr, _idx: _idx)
    # when epos.vp?
    #   VpNode.new(list, epos, attr: attr, _idx: _idx)
    # when list.size == 2
    #   M2Node.new(list[0], list[1], epos, attr: attr, _idx: _idx)
    # when list.size == 3
    #   M3Node.new(list[0], list[1], list[2], epos, attr: attr, _idx: _idx)
    # else
    #   MxNode.new(list, epos, attr: attr, _idx: _idx)
    # end

    AiTerm.new(
      epos: epos, attr: attr,
      orig: body, tran: tran,
      dnum: :unknown_0, from: from, upto: upto
    )
  end

  def find_defn(zstr : String, epos : MtEpos, attr : MtAttr, body : String | Array(RawCon))
    @dicts.each { |d| d.get?(zstr, epos).try { |x| return x } }

    case epos
    when .pu?, .url?
      vstr = CharUtil.normalize(zstr)
      attr = MtAttr.parse_punct(zstr)
    when .em?
      vstr = zstr
      attr = MtAttr[Asis, Capx]
    when .od?
      vstr = TlUnit.translate_od(zstr)
    when .cd?
      vstr = TlUnit.translate_od(zstr)
    when .qp?
      return unless vstr = TlUnit.translate_od(zstr)
    else
      return
    end

    defn = MtTerm.new(vstr: vstr, attr: attr, dnum: :autogen_0, fpos: epos)
    @dicts.last.add(zstr, epos, defn)
  end

  def get_any_defn?(zstr : String)
    @dicts.each { |d| d.any?(zstr).try { |x| return x } }
  end
end
