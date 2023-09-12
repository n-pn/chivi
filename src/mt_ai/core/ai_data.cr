require "http/client"

require "./ai_node/*"
require "./ai_dict"

# references:
# - https://hanlp.hankcs.com/docs/annotations/pos/ctb.html
# - https://hanlp.hankcs.com/docs/annotations/constituency/ctb.html

class MT::AiData
  getter root : AiNode

  delegate zstr, to: @root

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

  def to_json
    JSON.build { |jb| to_json(jb) }
  end

  def to_json(io : IO) : Nil
    JSON.build(io) { |jb| @root.to_json(jb: jb) }
  end

  def to_json(jb : JSON::Builder) : Nil
    @root.to_json(jb: jb)
  end

  def translate!(dict : AiDict, rearrange : Bool = true)
    @root.translate!(dict, rearrange: rearrange)
    self
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

      ipos, attr = init_attr_from_cpos(cpos)
      return {M0Node.new(zstr.to_s, cpos, _idx, attr, ipos), _idx + size}
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
    ipos, attr = init_attr_from_cpos(cpos)

    case
    when size == 1
      {M1Node.new(nodes[0], cpos, from, attr, ipos), _idx}
    when cpos == "NP"
      {NpNode.new(nodes, cpos, from, attr, ipos), _idx}
    when cpos == "VP"
      {VpNode.new(nodes, cpos, from, attr, ipos), _idx}
    when size == 2
      {M2Node.new(nodes[0], nodes[1], cpos, from, attr, ipos), _idx}
    when size == 3
      {M3Node.new(nodes[0], nodes[1], nodes[2], cpos, from, attr, ipos), _idx}
    else
      {MxNode.new(nodes, cpos, from, attr, ipos), _idx}
    end
  end

  def self.init_attr_from_cpos(cpos)
    cpos, *tags = cpos.split('-')

    case cpos
    when "NR" then attr = MtAttr::Npos
    when "NT" then attr = MtAttr::Ntmp
    else           attr = MtAttr::None
    end

    tags.each do |ctag|
      case ctag
      when "PN"  then attr |= MtAttr[Nper, Npos]
      when "TMP" then attr |= MtAttr[Ntmp]
      end
    end

    {MtCpos[cpos], attr}
  end
end