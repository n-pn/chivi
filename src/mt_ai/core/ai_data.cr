require "http/client"

require "./ai_node/*"
require "./ai_dict"

# references:
# - https://hanlp.hankcs.com/docs/annotations/pos/ctb.html
# - https://hanlp.hankcs.com/docs/annotations/constituency/ctb.html

class MT::AiData
  getter root : AiNode

  delegate zstr, to: @root
  delegate tl_word!, to: @root
  delegate tl_phrase!, to: @root

  def initialize(@root : AiNode)
  end

  ###

  def inspect(io : IO)
    @root.inspect(io)
  end

  def to_txt(cap : Bool = true, und : Bool = true)
    String.build { |io| to_txt(io, cap: cap, und: und) }
  end

  def to_txt(io : IO, cap : Bool, und : Bool) : Nil
    @root.to_txt(io, cap: cap, und: und)
  end

  def to_mtl(cap : Bool = true, und : Bool = true)
    String.build { |io| to_mtl(io, cap: cap, und: und) }
  end

  def to_mtl(io : IO, cap : Bool, und : Bool) : Nil
    @root.to_mtl(io: io, cap: cap, und: und)
  end

  ###

  def self.parse_con_data(input : String)
    iter = input.each_char
    iter.next # remove first '(' character
    node, _idx = do_parse_con_data(iter, _idx: 0)
    new(node)
  end

  private def self.do_parse_con_data(iter, _idx = 0)
    sbuf = String::Builder.new
    from = _idx

    while char = iter.next
      break if char == ' '
      sbuf << char
    end

    cpos = sbuf.to_s
    char = iter.next.as(Char)

    if char != '(' # core term
      zstr = String::Builder.new
      zstr << CharUtil.to_canon(char, true)
      size = 1

      while char = iter.next.as(Char)
        break if char == ')'
        zstr << CharUtil.to_canon(char, true)
        size &+= 1
      end

      cpos, prop = init_prop_from_cpos(cpos)
      return {M0Node.new(zstr.to_s, cpos, _idx, prop), _idx + size}
    end

    nodes = [] of AiNode

    while true
      node, _idx = self.do_parse_con_data(iter, _idx)
      nodes << node

      char = iter.next.as(Char)
      break if char == ')'
      iter.next if char == ' '
    end

    # pp nodes

    size = nodes.size
    cpos, prop = init_prop_from_cpos(cpos)

    case
    when size == 1    then {M1Node.new(nodes[0], cpos, from, prop), _idx}
    when cpos == "NP" then {NpNode.new(nodes, cpos, from, prop), _idx}
    when cpos == "VP" then {VpNode.new(nodes, cpos, from, prop), _idx}
    when size == 2    then {M2Node.new(nodes[0], nodes[1], cpos, from, prop), _idx}
    when size == 3    then {M3Node.new(nodes[0], nodes[1], nodes[2], cpos, from, prop), _idx}
    else                   {MxNode.new(nodes, cpos, from, prop), _idx}
    end
  end

  def self.init_prop_from_cpos(cpos)
    cpos, *tags = cpos.split('-')

    prop = case cpos
           when "NR" then MtProp::Npos
           when "NT" then MtProp::Ntmp
           else           MtProp::None
           end

    tags.each do |ctag|
      case ctag
      when "PN"  then prop |= MtProp[Nper, Npos]
      when "TMP" then prop |= MtProp[Ntmp]
      end
    end

    {cpos, prop}
  end
end
