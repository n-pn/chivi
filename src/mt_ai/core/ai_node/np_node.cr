require "./ai_node"
require "./ai_rule"

class MT::NpNode
  include AiNode

  getter orig : Array(AiNode)
  getter data = [] of AiNode

  private def rearrange!(dict : AiDict) : Array(AiNode)
    list = Array(AiNode).new
    last = self.read_node if @orig.last.epos.lcp?

    while @_pos >= 0
      node = self.read_node

      if @_pos >= 0 && node.epos.noun?
        node = read_nn!(dict: dict, list: [node] of AiNode, on_etc: false)
      end

      list.unshift(node)
    end

    list.insert(last.attr.at_t? ? -1 : 0, last) if last
    list
  end

  @[AlwaysInline]
  private def make_node(dict : AiDict, list : Array(AiNode),
                        epos : MtEpos = :NN, attr : MtAttr = :none)
    return list.first if list.size == 1
    node = MxNode.new(list, epos: epos, attr: attr)
    node.tap(&.tl_whole!(dict: dict))
  end

  private def read_nn!(dict : AiDict, list : Array(AiNode), on_etc = false) : AiNode
    attr = list.last.attr.turn_off(MtAttr[Sufx, Undb])

    while @_pos >= 0
      node = self.peak_node

      case node.epos
      when .noun?
        list.insert(on_etc ? 0 : -1, node)
        @_pos &-= 1
      when .adjp? # if current node is short modifier
        break unless node.attr.prfx?

        # combine the noun list for phrase translation
        noun = make_node(dict: dict, list: list, epos: :NN, attr: attr)
        node = M2Node.new(node, noun, epos: :NN, flip: !node.attr.at_h?, _idx: node._idx)
        list = [node.tap(&.tl_whole!(dict))] of AiNode

        @_pos &-= 1
      when .pu?
        # FIXME: check error in this part
        break if @_pos == 0 || node.zstr[0] != '､'

        list.unshift(node)
        @_pos &-= 1

        prev = self.peak_node
        break unless prev.epos.noun?

        @_pos &-= 1
        list.unshift(@_pos >= 0 ? read_nn!(dict, [prev] of AiNode, on_etc) : prev)
      else
        break
      end
    end

    read_np!(dict, list: [make_node(dict, list, attr: attr)] of AiNode)
  end

  private def read_np!(dict : AiDict, list : Array(AiNode)) : AiNode
    noun = list.last
    attr = noun.attr.turn_off(MtAttr[Sufx, Undb])

    while @_pos >= 0
      node = self.peak_node

      case node.epos
      when .od?, .cp?, .ip?, .lcp?
        list.push(node)
      when .cd?, .clp?
        list.unshift(node)
      when .qp?
        add_qp_to_list(list, node, noun)
      when .adjp?
        noun = make_node(dict, list, epos: :NP, attr: attr)
        node = M2Node.new(node, noun, epos: :NP, flip: !node.attr.at_h?, _idx: node._idx)
        list = [node.tap(&.tl_whole!(dict))] of AiNode
      when .dnp?, .dt?, .dp?
        list.insert(node.attr.at_h? ? 0 : -1, node)
      when .pn?
        at_h = pron_at_head?(pron: node, noun: noun)
        list.insert(at_h ? 0 : -1, node)
      else
        break
      end

      @_pos &-= 1
    end

    make_node(dict, list, epos: :NP, attr: attr)
  end

  private def pron_at_head?(pron : AiNode, noun : AiNode)
    true
  end

  private def add_qp_to_list(list, qp_node, nn_node) : Nil
    m_node = qp_node.find_by_epos(:M) || qp_node
    MtPair.m_n_pair.fix_if_match!(m_node, nn_node)

    unless qp_node.first.epos.od?
      list.unshift(qp_node)
      return
    end

    case qp_node
    when M1Node
      list.push(qp_node)
    when M2Node
      list.push(qp_node.lhsn)
      list.unshift(qp_node.rhsn)
    else
      # TODO: handle M3Node and MxNode
      list.unshift(qp_node)
    end
  end
end
