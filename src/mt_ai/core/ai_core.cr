require "../_raw/raw_con"
require "./mt_core/*"

class MT::AiCore
  CACHE = {} of String => self

  def self.load(pdict : String)
    CACHE[pdict] ||= new(pdict.sub("book", "wn").tr(":/", ""))
  end

  @dicts : {HashDict, HashDict, HashDict, HashDict}

  def initialize(@pdict : String)
    @dicts = {
      HashDict.load!(pdict),
      HashDict.regular,
      HashDict.essence,
      HashDict.suggest,
    }

    @name_qt = QtCore.new(pdict, "name_hv")
  end

  def translate!(data : RawCon, prfx : AiTerm)
    root = init_node(data, from: prfx.upto)
    root.prepend!(prfx)
  end

  def translate!(data : RawCon, prfx : Nil = nil)
    init_node(data, from: 0)
  end

  private def init_node(data : RawCon, from : Int32 = 0) : AiTerm
    zstr, orig = data.zstr, data.body
    epos, attr = MtEpos.parse_ctb(data.cpos, zstr)

    if orig.is_a?(String)
      init_mode = 2
    elsif orig.size > 1 && epos.can_use_alt?
      init_mode = 1
    else
      init_mode = 0
    end

    if defn = init_defn(zstr, epos, attr, mode: init_mode)
      return AiTerm.new(body: defn, zstr: zstr, epos: epos, attr: attr, from: from)
    elsif orig.is_a?(String)
      raise "invalid!"
    end

    body = init_body(orig, from)
    term = AiTerm.new(body, zstr: zstr, epos: epos, attr: attr, from: from)

    case epos
    when .np? then fix_np_term!(term, body)
      # when .vp? then fix_vp_term!(term, body)

    end

    term
  end

  MATCH_PUNCT = {
    '＂' => '＂',
    '“' => '”',
    '‘' => '’',
    '〈' => '〉',
    '（' => '）',
    '［' => '］',
  }

  private def init_body(orig : Array(RawCon), from : Int32 = 0)
    prev_upto = from
    stack = [{[] of AiTerm, '\0'}]

    prev_upto = from

    orig.each do |rcon|
      node = init_node(rcon, from: prev_upto)
      prev_upto = node.upto

      list, match_pu = stack.last

      if !node.epos.pu?
        list << node
      elsif node.zstr[-1] == match_pu
        list << node

        # for case that whole group is matching, just return the list
        return list if list.size == orig.size

        stack.pop # remove the pending list
        stack.last[0] << init_pu_term(list)
      elsif match_pu = MATCH_PUNCT[node.zstr[0]]?
        stack << {[node], match_pu}
      else
        list << node
      end
    end

    list = stack.flat_map(&.[0])

    case list.size
    when 1 then list[0]
    when 2 then AiPair.new(list[0], list[1])
    else        list
    end
  end

  private def init_pu_term(list : Array(AiTerm))
    # else, generate new list
    if list[-2].epos.pu?
      epos = MtEpos::IP
      attr = MtAttr::Capn
    else
      epos = MtEpos::X
      attr = MtAttr::None
    end
    init_term(list, epos, attr)
  end
end
