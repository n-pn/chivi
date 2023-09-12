require "./ai_node"
require "./ai_rule"

class MT::NpNode
  include AiNode

  getter orig = [] of AiNode
  getter data = [] of AiNode

  def initialize(@orig : Array(AiNode), @cpos, @_idx, @attr = :none, @ipos = MtCpos[cpos])
    @_pos = 0
    @zstr = orig.join(&.zstr)
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
    @data = read_np!(dict, _max: @orig.size) if rearrange
  end

  ###

  @[AlwaysInline]
  private def peak_node(_pos = @_pos)
    @orig[_pos]
  end

  @[AlwaysInline]
  private def read_node
    node = @orig[@_pos]
    @_pos &+= 1
    node
  end

  private def read_np!(dict : AiDict, _max = @orig.size) : Array(AiNode)
    data = Array(AiNode).new
    return data unless first_node = @orig[@_pos]?

    i_hd = 0
    i_tl = -1

    if first_node.first.ipos == MtCpos::PN
      # TODO: handle PN as head
      data << first_node
      @_pos &+= 1
      i_hd &+= 1
    end

    qp_node : AiNode? = nil # hold quantifier for correction

    while @_pos < _max
      node = self.read_node

      case node.ipos
      when MtCpos::CD
        data.insert(i_hd, node)
        i_hd &+= 1
      when MtCpos::OD
        data.insert(i_tl, node)
        i_tl &-= 1
      when MtCpos::QP
        qp_node = node
        data.insert(i_hd, node)
        i_hd &+= 1
      when MtCpos::DP
        dt_node, qp_node = AiRule.split_dp(node)
        if dt_node.attr.at_h?
          data.insert(i_hd, dt_node)
          i_hd &+= 1
        else
          data.insert(i_tl, dt_node)
          i_tl &-= 1
        end

        if qp_node
          data.insert(i_hd, qp_node)
          i_hd &+= 1
        end
      when MtCpos["CLP"]
        # FIXME: split phrase if first element is CD
        data.insert(i_hd, node)
      when MtCpos["DNP"]
        if node.attr.at_h?
          data.insert(i_hd, node)
          i_hd &+= 1
        else
          data.insert(i_tl, node)
          i_tl &-= 1
        end
      when MtCpos::PU
        if match_found = AiRule.find_matching_pu(orig, node, _idx: @_pos, _max: _max)
          # TODO: check flipping
          match_tail, match_max = match_found
          node = read_pu!(dict, node, match_tail, match_max)
          data.insert(i_hd, node)
          @_pos = match_max
        else
          i_tl = -1
          data.insert(i_tl, node)
          i_hd = data.size
        end
      when MtCpos["CC"]
        data.insert(i_tl, node)
        i_hd = data.size &+ i_tl &+ 1
      when MtCpos["PRN"], MtCpos["ETC"], MtCpos["FLR"]
        data.insert(i_tl, node)
        i_hd = data.size &+ i_tl &+ 1
      when MtCpos::NN, MtCpos::NP, MtCpos::NR
        # TODO: consume node

        if qp_node
          MtPair.fix_m_n_pair!(qp_node, node)
          qp_node = nil
        end

        data.insert(i_hd, node)
      else
        data.insert(i_hd, node)
      end
    end

    data
  end

  def skip_node!
    @_pos += 1
  end

  private def read_pu!(dict : AiDict, head : AiNode, tail : AiNode, _max : Int32)
    inner_list = [] of AiNode
    @_pos.upto(_max &- 2) { |_pos| inner_list << peak_node(_pos) }

    inner_cpos = inner_list.last.ipos == MtCpos::PU ? "IP" : "NP"
    inner_node = NpNode.new(inner_list, inner_cpos, _idx: inner_list.first._idx)
    inner_node.translate!(dict, true)

    outer_node = M3Node.new(head, inner_node, tail, "NP", _idx: head._idx)
    outer_node.translate!(dict, true)

    outer_node
  end
end