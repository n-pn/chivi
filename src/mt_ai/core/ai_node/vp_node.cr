require "./ai_node"

class MT::VpNode
  include AiNode

  getter orig = [] of AiNode
  getter data = [] of AiNode

  def initialize(@orig, @cpos, @_idx, @attr = :none, @ipos = MtCpos[cpos])
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

  def translate!(dict : AiDict, rearrange : Bool = true) : Nil
    self.tl_whole!(dict: dict)
    @orig.each(&.translate!(dict, rearrange: rearrange))
    @data = read_vp!(dict) if rearrange
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

    v_node = @orig.reverse_each.find(@orig.last) { |x| MtCpos.verb?(x.ipos) }
    v_stem = v_node.first.zstr

    n_node = nil

    while @_pos < _max
      node = read_node

      case node.ipos
      when MtCpos::ADVP
        node = AiRule.heal_advp!(dict, node)
        data.insert(i_tl, node)
        i_tl -= 1 if node._idx < v_node._idx && node.attr.at_t?
      when MtCpos::PP
        if node._idx < v_node._idx
          node = AiRule.heal_pp!(dict, node, v_node)
          data.insert(i_tl, node)
          i_tl -= 1 if node.attr.at_t?
        else
          data.insert(i_tl, node)
        end
      when MtCpos::AS
        if node.zstr == "了" && @_pos == _max && !node.attr.asis?
          node.set_vstr!("rồi")
          node.off_attr!(:hide)
          data.insert(i_tl, node)
        else
          # TODO: add tense if no adverb
          data.insert(i_hd, node)
          i_hd += 1
        end
      when MtCpos::IP
        if !n_node && v_stem == "想"
          v_node.set_vstr!("muốn")
        end

        data.insert(i_tl, node)
      when MtCpos::NP
        # TODO: fix meaning
        if node.attr.nper? && v_stem == "想"
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
