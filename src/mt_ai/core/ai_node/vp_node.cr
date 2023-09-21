require "./ai_node"

class MT::VpNode
  include AiNode

  getter orig = [] of AiNode
  getter data = [] of AiNode

  def initialize(@orig, @epos, @_idx, @attr = :none)
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
    @orig[_pos]
  end

  @[AlwaysInline]
  private def read_node
    @orig[@_pos].tap { @_pos &+= 1 }
  end

  ##

  def read_vp!(dict : AiDict, _max = @orig.size) : Array(AiNode)
    head = [] of AiNode

    verb = while @_pos < _max
      node = read_node
      break node if node.epos.verb?
      head << node
    end

    return head unless verb

    data = [] of AiNode
    tail = [] of AiNode

    head.each do |node|
      case node.epos
      when .advp?
        fix_d_v_pair!(node, verb)
        # TODO: check if aspect existed
      when .pp?
        fix_p_v_pair!(node, verb)
      end

      if node.attr.at_t?
        tail << node
      else
        data << node
      end
    end

    # TODO: split verb?
    data << read_vo!(dict, verb, _max)
    tail.reverse_each { |node| data << node }

    while @_pos < _max
      data << self.read_node
    end

    data
  end

  def read_vo!(dict : AiDict, verb : AiNode, _max : Int32)
    iobj = dobj = nil

    while @_pos < _max
      node = self.peak_node

      case node.epos
      when .is?(:AS)
        verb = M2Node.new(verb, node, :VP, attr: verb.attr)
        verb.tl_whole!(dict: dict)
      when .is?(:QP)
        verb = M2Node.new(verb, node, :VP, attr: verb.attr)
      when .is?(:NP)
        break if dobj
        break unless !iobj && node.attr.nper? || verb.attr.vdit?
        iobj = node
      when .vv?, .ip?, .vp?, .pp?
        break if dobj
        dobj = node
      else
        break
      end

      @_pos &+= 1
    end

    if iobj && !dobj
      dobj = iobj
      iobj = nil
    elsif !dobj
      return verb
    end

    stem = verb.first

    case stem.zstr
    when "想" then fix_xiang!(stem, dobj)
    end

    iobj ? M3Node.new(verb, iobj, dobj, epos: :VP) : M2Node.new(verb, dobj, epos: :VP)
  end

  def fix_xiang!(vv_node : AiNode, do_node : AiNode) : Nil
    do_node = do_node.first if do_node.epos.is?(:IP)

    case do_node.epos
    when .vp?, .vv?, .pp?
      vv_node.set_vstr!("muốn")
    when .np?
      vv_node.set_vstr!("nhớ")
    else
      vv_node.set_vstr!("nghĩ")
    end
  end

  def fix_d_v_pair!(ad_node : AiNode, vv_node : AiNode) : Nil
    case ad_node.zstr
    when "好"
      ad_node.set_vstr!(vv_node.epos.is?(:VA) ? "thật" : "dễ")
    when "多"
      ad_node.set_vstr!(vv_node.epos.is?(:VA) ? "bao" : "nhiều")
    end

    MtPair.d_v_pair.fix_if_match!(ad_node, vv_node)
  end

  def fix_p_v_pair!(pp_node : AiNode, vv_node : AiNode) : Nil
    return unless p_node = pp_node.find_by_epos(:P)
    MtPair.p_v_pair.fix_if_match!(p_node, vv_node)
    pp_node.add_attr!(p_node.attr)
  end

  def fix_v_o_pair!(vv_node : AiNode, nn_node : AiNode) : Nil
    # TODO!
  end
end
