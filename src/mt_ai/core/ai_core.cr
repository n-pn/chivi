require "../_raw/raw_con"
require "./ai_node/*"
require "./mt_core/*"

class MT::AiCore
  getter dict : AiDict

  def initialize(pdict : String)
    @dict = AiDict.load(pdict)
  end

  def translate!(data : RawCon, pre : Nil = nil)
    init_node(data, _idx: 0).tap(&.translate!(dict: @dict))
  end

  def translate!(data : RawCon, pre : AiNode)
    root = init_node(data, _idx: pre.zstr.size)
    root.as(MxNode).list.unshift(pre)
    root.tap(&.translate!(dict: @dict))
  end

  private def make_m0_node!(zstr : String, epos : MtEpos, attr : MtAttr, _idx : Int32)
    node = M0Node.new(zstr, epos, attr: attr, _idx: _idx)
    node.tap(&.set_term!(dict.get(zstr, epos)))
  end

  private def make_ai_node!(body : Array(RawCon), epos : MtEpos, attr : MtAttr, _idx : Int32)
    # zstr =
  end

  private def init_node(data : RawCon, _idx : Int32 = 0)
    epos, attr = MtEpos.parse_ctb(data.cpos)
    zstr, body = data.zstr, data.body

    return make_m0_node!(body, epos, attr, _idx) if body.is_a?(String)

    from = _idx
    list = [] of AiNode

    body.each do |raw|
      node = init_node(raw, _idx: from)
      from += node.zstr.size
      list << node
    end

    case
    when epos.top?
      MxNode.new(list, epos, attr: attr, _idx: _idx)
    when list.size == 1
      M1Node.new(list[0], epos, attr: attr, _idx: _idx)
    when epos.np?
      NpNode.new(list, epos, attr: attr, _idx: _idx)
    when epos.vp?
      VpNode.new(list, epos, attr: attr, _idx: _idx)
    when list.size == 2
      M2Node.new(list[0], list[1], epos, attr: attr, _idx: _idx)
    when list.size == 3
      M3Node.new(list[0], list[1], list[2], epos, attr: attr, _idx: _idx)
    else
      MxNode.new(list, epos, attr: attr, _idx: _idx)
    end
  end
end
