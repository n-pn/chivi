require "./ai_node"
require "./ai_rule"

class MT::NpNode
  include AiNode

  getter orig = [] of AiNode
  getter data = [] of AiNode

  def initialize(@orig : Array(AiNode), @cpos, @_idx, @prop = :none)
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
  def tl_phrase!(dict : AiDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_term!(*found)
    else
      @orig.each(&.tl_phrase!(dict))
      @data = read_np!(dict, _max: @orig.size)
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict) : Nil
    @orig.each(&.tl_word!(dict))
    @data = read_np!(dict, _max: @orig.size)
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

    if first_node.first.cpos == "PN"
      # TODO: handle PN as head
      data << first_node
      @_pos &+= 1
      i_hd &+= 1
    end

    q_node : AiNode? = nil # hold quantifier for correction

    while @_pos < _max
      node = self.read_node

      case node.cpos
      when "CD"
        data.insert(i_hd, node)
        i_hd &+= 1
      when "OD"
        data.insert(i_tl, node)
        i_tl &-= 1
      when "QP"
        q_node = node.find_by_cpos("M")
        data.insert(i_hd, node)
        i_hd &+= 1
      when "DP"
        dt_node, mq_node = AiRule.split_dp(node)
        if dt_node.prop.at_h?
          data.insert(i_hd, dt_node)
          i_hd &+= 1
        else
          data.insert(i_tl, dt_node)
          i_tl &-= 1
        end

        if mq_node
          data.insert(i_hd, mq_node)
          i_hd &+= 1
        end
      when "CLP"
        # FIXME: split phrase if first element is CD
        data.insert(i_hd, node)
      when "DNP"
        if node.prop.at_h?
          data.insert(i_hd, node)
          i_hd &+= 1
        else
          data.insert(i_tl, node)
          i_tl &-= 1
        end
      when "PU"
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
      when "CC"
        data.insert(i_tl, node)
        i_hd = data.size &+ i_tl &+ 1
      when "PRN", "ETC", "FLR"
        data.insert(i_tl, node)
        i_hd = data.size &+ i_tl &+ 1
      when "NN", "NP", "NR"
        # TODO: consume node

        if q_node
          MtDefn.fix_m_n_pair!(q_node, node)
          q_node = nil
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

    inner_cpos = inner_list.last.cpos == "PU" ? "IP" : "NP"
    inner_node = NpNode.new(inner_list, inner_cpos, _idx: inner_list.first._idx)
    inner_node.tl_phrase!(dict)

    outer_node = M3Node.new(head, inner_node, tail, "NP", _idx: head._idx)
    outer_node.tl_phrase!(dict)
    outer_node
  end
end
