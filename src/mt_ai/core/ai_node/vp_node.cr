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

    stem = find_stem(verb)

    head.each do |node|
      case node.epos
      when .advp?
        fix_d_v_pair!(node, stem)
        # TODO: check if aspect existed
      when .pp?
        fix_p_v_pair!(node, stem)
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
        break if dobj || !@orig[@_pos &+ 1]?.try(&.epos.noun?)
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

    stem = find_stem(verb)

    case stem.zstr
    when "想" then fix_vm_xiang!(stem, dobj)
    when "会" then fix_vm_hui!(stem, dobj)
    else
      fix_v_n_pair!(stem, dobj) if dobj.epos.noun?
    end

    iobj ? M3Node.new(verb, iobj, dobj, epos: :VP) : M2Node.new(verb, dobj, epos: :VP)
  end

  def fix_vm_xiang!(vv_node : AiNode, do_node : AiNode) : Nil
    do_node = do_node.first if do_node.epos.is?(:IP)

    case do_node.epos
    when .vp?, .vv?, .pp?
      vv_node.set_vstr!("muốn")

      while !do_node.is_a?(M0Node)
        do_node = do_node.first
      end

      return unless do_node.zstr == "要"

      do_node.set_vstr!("")
      do_node.add_attr!(:Hide)
    when .np?
      vv_node.set_vstr!("nhớ")
    else
      vv_node.set_vstr!("nghĩ")
    end
  end

  def fix_vm_hui!(vv_node : AiNode, do_node : AiNode) : Nil
    # TODO!
  end

  def fix_d_v_pair!(ad_node : AiNode, vv_node : AiNode) : Nil
    case ad_node.zstr
    when "好"
      ad_node.set_vstr!(vv_node.epos.is?(:VA) ? "thật" : "dễ")
    when "多"
      if vv_node.epos.is?(:VA)
        ad_node.set_vstr!("bao")
      else
        ad_node.set_vstr!("nhiều")
        ad_node.add_attr!(:at_t)
      end
    end

    MtPair.d_v_pair.fix_if_match!(ad_node, vv_node)
  end

  def fix_p_v_pair!(pp_node : AiNode, vv_node : AiNode) : Nil
    return unless p_node = pp_node.find_by_epos(:P)

    MtPair.p_v_pair.fix_if_match!(p_node, vv_node)
    pp_node.add_attr!(:At_t) if p_node.attr.at_t?
  end

  def fix_v_n_pair!(vv_node : AiNode, nn_node : AiNode) : Nil
    MtPair.v_n_pair.fix_if_match!(vv_node, nn_node)
  end

  @[AlwaysInline]
  def find_stem(node : AiNode) : AiNode
    while node.epos.is?(:VP) && !node.is_a?(M0Node)
      node = node.first
    end

    node
  end
end
