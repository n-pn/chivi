require "./ai_node"
require "./ai_rule"

class MT::NpNode
  include AiNode

  getter orig : Array(AiNode)
  getter data = [] of AiNode

  def initialize(input : Array(AiNode), @epos, @attr = :none, @_idx = input.first._idx)
    @zstr = input.join(&.zstr)
    @orig = correct_input(input)
    @_pos = @orig.size &- 1
  end

  private def correct_input(input : Array(AiNode))
    pos = 0
    max = input.size
    res = Array(AiNode).new(initial_capacity: max)

    while pos < max
      node = input[pos]
      pos &+= 1

      case node.epos
      when .nr?
        if !(succ = input[pos]?)
          res << node
        elsif succ.attr.sufx?
          succ.set_epos!(:NH)
          attr = succ.attr.turn_off(MtAttr[Sufx, At_h])
          res << M2Node.new(node, succ, epos: :NR, attr: attr, flip: succ.attr.at_h?)
          pos &+= 1
        elsif succ.epos.nr?
          res << node
        else
          res << node << succ
          pos &+= 1
        end
      when .pu?
        if found = AiRule.find_matching_pu(input, node, _idx: pos, _max: max)
          # TODO: check flipping
          tail, fmax = found
          list = input[pos..(fmax - 2)]

          if list.last.epos.pu?
            node.add_attr!(:capn)
            midn = MxNode.new(list, epos: :IP)
          else
            midn = NpNode.new(list, epos: :NP)
          end

          res << M3Node.new(node, midn, tail, epos: :NP, _idx: node._idx)
          pos = fmax
        else
          res << node
        end
      when .dp?
        split_dp_and_add_to_list(res, node)
      else
        res << node
      end
    end

    res
  end

  @[AlwaysInline]
  private def split_dp_and_add_to_list(list : Array(AiNode), node : AiNode) : Nil
    case node
    when M1Node
      if node.zstr.size < 2 || !node.zstr[0].in?('这', '那')
        list << node
      else
        list << M0Node.new(node.zstr[0].to_s, epos: :DT, _idx: node._idx)
        list << M0Node.new(node.zstr[1..], epos: :QP, _idx: node._idx + 1)
      end
    when M2Node
      list << node.lhsn
      list << node.rhsn
    else
      list << node
    end
  end

  def z_each(&)
    @orig.each { |node| yield node }
  end

  def v_each(&)
    list = @data.empty? ? @orig : @data
    list.each { |node| yield node }
  end

  def first
    @orig.first
  end

  def last
    @orig.last
  end

  ###

  @[AlwaysInline]
  def translate!(dict : AiDict, rearrange : Bool = true)
    self.tl_whole!(dict: dict)
    @orig.each(&.translate!(dict, rearrange: rearrange))
    @data = rearrange!(dict) if rearrange
  end

  ###

  @[AlwaysInline]
  private def peak_node(_pos = @_pos)
    @orig[_pos]
  end

  @[AlwaysInline]
  private def read_node
    @orig[@_pos].tap { @_pos &-= 1 }
  end

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
        node = node.find_by_epos(:M) || node
        MtPair.m_n_pair.fix_if_match!(node, noun)

        list.unshift(node)
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
end
