require "./ai_node"
require "./ai_rule"

class MT::NpNode
  include AiNode

  getter orig : Array(AiNode)
  getter data = [] of AiNode

  def initialize(input : Array(AiNode), @cpos, @_idx = input.first._idx, @attr = :none, @ipos = MtCpos[cpos])
    @zstr = input.join(&.zstr)

    @orig = correct_input(input)
    @_pos = @orig.size &- 1
  end

  private def correct_input(input : Array(AiNode))
    pos = 0
    max = input.size
    res = Array(AiNode).new(initial_capacity: max)

    while pos < max
      node = input.unsafe_fetch(pos)
      pos &+= 1

      # TODO: split DP, QP
      case node.ipos
      when MtCpos::DP
        dt_node, qp_node = AiRule.split_dp(node)
        res << dt_node
        res << qp_node if qp_node
      when MtCpos::NR
        if !(succ = input[pos]?)
          res << node
        elsif succ.attr.sufx?
          succ.off_attr!(:sufx)
          res << M2Node.new_nr(node, succ, attr: succ.attr)
          pos &+= 1
        elsif succ.ipos != MtCpos::NR
          res << node << succ
          pos &+= 1
        else
          res << node
        end
      when MtCpos::PU
        if found = AiRule.find_matching_pu(input, node, _idx: pos, _max: max)
          # TODO: check flipping
          tail, fmax = found
          list = input[pos...fmax]

          if list.last.ipos == MtCpos::PU
            node.add_attr!(:capn)
            inner_node = MxNode.new(list, cpos: "IP", ipos: MtCpos::IP)
          else
            inner_node = NpNode.new(list, cpos: "NP", ipos: MtCpos::NP)
          end

          res << M3Node.new(node, inner_node, tail, cpos: "NP", ipos: MtCpos::NP)
          pos = fmax
        else
          res << node
        end
      else
        res << node
      end
    end

    res
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

    last = self.read_node if @orig.last.ipos == MtCpos::LCP

    while @_pos >= 0
      node = self.read_node

      if @_pos >= 0 && node.ipos.in?(MtCpos::NN, MtCpos::NP, MtCpos::NR)
        node = read_nn!([node] of AiNode, false)
        node.tl_whole!(dict: dict)
      end

      list.unshift(node)
    end

    list.insert(last.attr.at_t? ? -1 : 0, last) if last
    list
  end

  private def make_node(list : Array(AiNode), attr = list.last.attr,
                        ipos = MtCpos::NN, cpos = MtCpos::ALL[ipos]) : AiNode
    case list.size
    when 1
      list.first
    when 2
      M2Node.new(list.first, list.last, cpos: cpos, ipos: ipos, attr: attr)
    else
      MxNode.new(list, cpos: cpos, ipos: ipos, attr: attr)
    end
  end

  private def read_nn!(list : Array(AiNode), on_etc = false) : AiNode
    attr = list.last.attr

    while @_pos >= 0
      node = self.peak_node

      case node.ipos
      when MtCpos::NN, MtCpos::NP, MtCpos::NR
        list.insert(on_etc ? 0 : -1, node)
        @_pos &-= 1
      when MtCpos::ADJP # if current node is short modifier
        break unless node.attr.prfx?

        # combine the noun list for phrase translation
        noun = make_node(list, attr: attr)
        list = node.attr.at_h? ? [node, noun] of AiNode : [noun, node] of AiNode

        @_pos &-= 1
      when MtCpos::PU
        # FIXME: check error in this part
        break if @_pos == 0 || node.zstr[0] != '､'

        list.unshift(node)
        @_pos &-= 1

        prev = self.peak_node
        break unless prev.in?(MtCpos::NN, MtCpos::NP, MtCpos::NR)

        @_pos &-= 1
        list.unshift(@_pos >= 0 ? read_nn!([prev] of AiNode, on_etc) : prev)
      else
        break
      end
    end

    read_np!([make_node(list, attr: attr)] of AiNode)
  end

  private def read_np!(list : Array(AiNode)) : AiNode
    noun = list.last

    while @_pos >= 0
      node = self.peak_node

      case node.ipos
      when MtCpos::OD, MtCpos::CP, MtCpos::IP
        list.push(node)
      when MtCpos::QP
        MtPair.fix_m_n_pair!(node, noun)
        list.unshift(node)
      when MtCpos::CD, MtCpos::CLP
        list.unshift(node)
      when MtCpos::DNP, MtCpos::ADJP, MtCpos::DT, MtCpos::DP
        list.insert(node.attr.at_h? ? 0 : -1, node)
      when MtCpos::LCP
        list.push(node)
      when MtCpos::PN
        at_h = pron_at_head?(pron: node, noun: noun)
        list.insert(at_h ? 0 : -1, node)
      else
        break
      end

      @_pos &-= 1
    end

    make_node(list, attr: noun.attr, ipos: MtCpos::NP, cpos: "NP")
  end

  private def pron_at_head?(pron : AiNode, noun : AiNode)
    true
  end
end
