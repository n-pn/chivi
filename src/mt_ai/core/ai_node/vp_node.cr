require "./ai_node"

class MT::VpNode
  include AiNode

  getter orig = [] of AiNode
  getter data = [] of AiNode

  @_pos = 0

  def initialize(input, @epos, @_idx, @attr = :none)
    @zstr = input.join(&.zstr)
    @orig = correct_input(input)
  end

  private def correct_input(input : Array(AiNode))
    pos = 0
    max = input.size
    res = Array(AiNode).new(initial_capacity: max)

    while pos < max
      node = input[pos]
      pos &+= 1

      case node.epos
      when .vv?
        if node.zstr.size > 1
          split_vv(res, node)
        else
          res << node
        end
      else
        res << node
      end
    end

    res
  end

  private def split_vv(list : Array(AiNode), node : AiNode) : Nil
    zstr = node.zstr
    attr = node.attr
    _idx = node._idx

    case
    when match = MtPair.v_c_pair.split_sufx(zstr)
      # TODO: remove MtPair.split_sufx and using better function
      v_zstr, c_zstr, c_term = match
      v_node = M0Node.new(v_zstr, :VV, attr: attr, _idx: _idx)

      c_attr = c_term.a_attr || MtAttr::Sufx
      c_node = M0Node.new(c_zstr, MtEpos::VR, attr: c_attr, _idx: _idx &+ v_zstr.size)
      c_node.set_vstr!(c_term.a_vstr)

      list << M2Node.new(v_node, c_node, epos: :VRD, attr: attr, _idx: _idx)
    when zstr[-1] == '了'
      list << M0Node.new(node.zstr[0..-2], :VV, attr, _idx)
      list << M0Node.new("了", :AS, :none, _idx: _idx &+ zstr.size &- 1)
    when zstr[0] == '一'
      list << M0Node.new("一", :AD, attr: attr, _idx: _idx)
      list << M0Node.new(zstr[1..], :VV, attr: attr, _idx: _idx &+ 1)
    when zstr[0] == '吓'
      lhsn = M0Node.new("吓", :VV, :none, _idx)
      rhsn = M0Node.new(zstr[1..], :VV, attr, _idx &+ 1)
      list << M2Node.new(lhsn, rhsn, epos: :VCD, attr: attr, _idx: _idx)
    else
      list << node
    end
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
    prfx = nil

    hmax = head.size &- 1
    head.each_with_index do |node, i|
      case node.epos
      when .advp?
        fix_d_v_pair!(node, stem)
        # TODO: check if aspect existed
      when .pp?
        fix_p_v_pair!(node, stem)
      end

      if node.attr.prfx? && i == hmax
        prfx = node
      elsif node.attr.at_t?
        tail << node
      else
        data << node
      end
    end

    verb = combine_with_prfx(dict, verb, prfx) if prfx

    # TODO: split verb?
    data << read_vo!(dict, verb, _max)
    tail.reverse_each { |x| data << x }

    while @_pos < _max
      data << self.read_node
    end

    data
  end

  def combine_with_prfx(dict, verb, prfx) : AiNode
    root = verb
    prev = nil

    while !verb.is_a?(M0Node)
      prev = verb
      if verb.is_a?(VpNode)
        verb = verb.data.first
      else
        verb = prev.first
      end
    end

    verb = M2Node.new(prfx, verb, :VV, attr: verb.attr, flip: prfx.attr.at_t?, _idx: prfx._idx)
    verb.tl_whole!(dict: dict)

    return verb unless prev

    case prev
    when M1Node
      prev.node = verb
    when M2Node, M3Node
      prev.lhsn = verb
    when MxNode
      prev.list[0] = verb
    when VpNode, NpNode
      prev.data[0] = verb
    end

    prev.zstr = "#{prfx.zstr}#{prev.zstr}"
    prev._idx = prfx._idx

    root
  end

  def read_vo!(dict : AiDict, verb : AiNode, _max : Int32)
    do_node = nil
    io_node = nil

    while @_pos < _max
      node = self.peak_node

      case node.epos
      when .is?(:AS)
        if node.zstr == "了"
          if @_pos &+ 1 < _max
            node.set_vstr!("⛶")
            node.add_attr!(:hide)
          elsif do_node || io_node
            node.set_epos!(:SP)
            break
          end
        end

        verb = M2Node.new(verb, node, :VAS, attr: verb.attr)
      when .is?(:QP)
        break if do_node || !@orig[@_pos &+ 1]?.try(&.epos.noun?)
        verb = M2Node.new(verb, node, :VP, attr: verb.attr)
        verb.tl_whole!(dict: dict)
      when .is?(:NP)
        if do_node
          break
        elsif io_node
          do_node = node
        else
          io_node = node
        end
      when .vv?, .ip?, .vp?, .pp?
        break if do_node
        do_node = node
      else
        break
      end

      @_pos &+= 1
    end

    if io_node && !do_node
      do_node = io_node
      io_node = nil
    elsif !do_node
      return verb
    end

    verb, tail = split_vnv!(verb) if verb.epos.vnv?

    stem = find_stem(verb)

    case stem.zstr
    when "想"  then fix_vm_xiang!(stem, do_node, nega: false)
    when "不想" then fix_vm_xiang!(stem, do_node, nega: true)
    when "会"  then fix_vm_hui!(stem, do_node, nega: false)
    when "不会" then fix_vm_hui!(stem, do_node, nega: true)
    else
      fix_v_n_pair!(stem, do_node) if do_node.epos.noun?
    end

    list = [verb] of AiNode
    list << io_node if io_node
    list << do_node
    list << tail if tail

    case list.size
    when 1 then list.first
    when 2 then M2Node.new(list.first, list.last, epos: :VP).tap(&.tl_whole!(dict: dict))
    else        MxNode.new(list, epos: :VP).tap(&.tl_whole!(dict: dict))
    end
  end

  def fix_vm_xiang!(vv_node : AiNode, do_node : AiNode, nega : Bool = false) : Nil
    do_node = do_node.first if do_node.epos.is?(:IP)

    case do_node.epos
    when .vp?, .vv?, .pp?
      vv_node.set_vstr!(nega ? "không muốn" : "muốn")

      while !do_node.is_a?(M0Node)
        do_node = do_node.first
      end

      return unless do_node.zstr == "要"

      do_node.set_vstr!("")
      do_node.add_attr!(:Hide)
    when .np?
      vv_node.set_vstr!(nega ? "không nhớ" : "nhớ")
    else
      vv_node.set_vstr!(nega ? "không nghĩ" : "nghĩ")
    end
  end

  def fix_vm_hui!(vv_node : AiNode, do_node : AiNode, nega : Bool = false) : Nil
    unless do_node.find_by_epos(:VV)
      vv_node.set_vstr!(nega ? "sẽ không" : "sẽ")
    end

    # TODO!
  end

  def fix_d_v_pair!(ad_node : AiNode, vv_node : AiNode) : Nil
    case ad_node.zstr
    when "好"
      ad_node.set_vstr!(vv_node.epos.is?(:VA) ? "thật" : "dễ")
    when "多"
      if vv_node.epos.is?(:VA)
        ad_node.set_vstr!("bao")
        ad_node.add_attr!(:at_h)
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

  def split_vnv!(verb : M3Node)
    if verb.rhsn.zstr.in?("没", "不")
      tail = M2Node.new(verb.midn, verb.rhsn, epos: :VP)
      {verb.lhsn, tail}
    else
      {verb, nil}
    end
  end

  def split_vnv!(verb : M2Node)
    if verb.rhsn.zstr[0].in?("没", "不")
      {verb.lhsn, verb.rhsn}
      # {verb.lhsn, tail}
    else
      {verb, nil}
    end
  end

  def split_vnv!(verb : AiNode)
    {verb, nil}
  end
end
