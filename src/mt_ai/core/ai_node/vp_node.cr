require "./ai_node"

class MT::VpNode
  include AiNode

  getter orig = [] of AiNode
  getter data = [] of AiNode

  def initialize(@orig, @cpos, @_idx, @prop = :none)
    @_pos = 0
    @zstr = orig.join(&.zstr)
  end

  ###

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

  def tl_phrase!(dict : AiDict) : Nil
    if found = dict.get?(@zstr, @cpos)
      self.set_term!(*found)
    else
      @orig.each(&.tl_phrase!(dict))
      @data = read_vp!(dict)
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict) : Nil
    @orig.each(&.tl_word!(dict))
    @data = read_vp!(dict)
  end

  @[AlwaysInline]
  private def peak_node(_pos = @_pos)
    @orig.unsafe_fetch(_pos)
  end

  @[AlwaysInline]
  private def read_node
    node = @orig.unsafe_fetch(@_pos)
    @_pos &+= 1
    node
  end

  ##

  def read_vp!(dict : AiDict, _max = @orig.size) : Array(AiNode)
    data = [] of AiNode

    i_hd = 0
    i_tl = -1

    v_node = @orig.reverse_each.find(&.cpos.in?("VP", "VV")) || @orig.last
    v_stem = v_node.first.zstr

    n_node = nil

    while @_pos < _max
      node = read_node

      case node.cpos
      when "ADVP"
        node = AiRule.heal_advp!(dict, node)
        data.insert(i_tl, node)
        i_tl -= 1 if node._idx < v_node._idx && node.prop.at_t?
      when "PP"
        if node._idx < v_node._idx
          node = AiRule.heal_pp!(dict, node, v_stem || "_")
          data.insert(i_tl, node)
          i_tl -= 1 if node.prop.at_t?
        else
          data.insert(i_tl, node)
        end
      when "AS"
        if node.zstr == "了" && @_pos == _max && !node.prop.asis?
          node.set_vstr!("rồi")
          node.off_prop!(:hide)
          data.insert(i_tl, node)
        else
          # TODO: add tense if no adverb
          data.insert(i_hd, node)
          i_hd += 1
        end
      when "IP"
        if !n_node && v_stem == "想"
          v_node.set_vstr!("muốn")
        end

        data.insert(i_tl, node)
      when "NP"
        # TODO: fix meaning
        if node.prop.nper? && v_stem == "想"
          v_node.set_vstr!("nhớ")
        end

        n_node = node
        data.insert(i_tl, node)
      else
        data.insert(i_tl, node)
      end
    end

    data
  end
end
