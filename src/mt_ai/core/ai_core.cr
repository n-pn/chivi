require "../_raw/raw_con"
require "./ai_node/*"
require "./tl_chap"

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

  private def init_node(data : RawCon, _idx : Int32 = 0)
    epos, attr = MtEpos.parse_ctb(data.cpos)
    body = data.body
    return M0Node.new(body, epos, attr: attr, _idx: _idx) if body.is_a?(String)

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
