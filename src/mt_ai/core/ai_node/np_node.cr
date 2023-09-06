require "./ai_node"
require "./ai_rule"

class MT::NpNode
  include AiNode

  getter orig = [] of AiNode
  getter data = [] of AiNode

  def initialize(@orig : Array(AiNode), @cpos, @_idx)
    @_idx = 0
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
  private def peak_node(_idx = @_idx)
    @orig.unsafe_fetch(_idx)
  end

  @[AlwaysInline]
  private def read_node
    node = @orig.unsafe_fetch(@_idx)
    @_idx &+= 1
    node
  end

  private def read_np!(dict : AiDict, _max = @orig.size) : Array(AiNode)
    data = Array(AiNode).new

    i_hd = 0
    i_tl = -1

    q_node : AiNode? = nil # hold quantifier for correction

    while @_idx < _max
      node = self.read_node

      case node.cpos
      when "PN"
        # TODO: check special case
        data.insert(i_hd, node)
        i_hd &+= 1
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
        if dt_node.pecs.at_h?
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
        if node.pecs.at_h?
          data.insert(i_hd, node)
          i_hd &+= 1
        else
          data.insert(i_tl, node)
          i_tl &-= 1
        end
      when "PU"
        if match_found = AiRule.find_matching_pu(orig, node, _idx: @_idx, _max: _max)
          # TODO: check flipping
          match_tail, match_max = match_found
          node = read_pu!(dict, node, match_tail, match_max)
          pp [node]
          data.insert(i_hd, node)
          @_idx = match_max
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
        data.insert(i_hd, node)
      else
        data.insert(i_hd, node)
      end
    end

    data
  end

  def skip_node!
    @_idx += 1
  end

  private def read_pu!(dict : AiDict, head : AiNode, tail : AiNode, _max : Int32)
    inner_list = [] of AiNode
    @_idx.upto(_max &- 2) { |_idx| inner_list << peak_node(_idx) }

    inner_cpos = inner_list.last.cpos == "PU" ? "IP" : "NP"
    inner_node = NpNode.new(inner_list, inner_cpos, _idx: inner_list.first._idx)
    inner_node.tl_phrase!(dict)

    outer_node = M3Node.new(head, inner_node, tail, "NP", _idx: head._idx)
    outer_node.tl_phrase!(dict)
    outer_node
  end
end
