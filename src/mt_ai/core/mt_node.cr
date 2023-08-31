require "./mt_node/*"

# references:
# - https://hanlp.hankcs.com/docs/annotations/pos/ctb.html
# - https://hanlp.hankcs.com/docs/annotations/constituency/ctb.html

class AI::MtData
  def initialize(@data : MtNode)
  end

  def self.parse(input : String, cleaned = false)
    input = input.gsub(/\n[\t\s]+/, " ") unless cleaned

    iter = input.each_char
    iter.next # remove first '(' character
    node, _idx = parse(iter, _idx: 0)

    node
  end

  private def self.parse(iter, _idx = 0)
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
      zstr << char
      size = 1

      while char = iter.next.as(Char)
        break if char == ')'
        zstr << char
        size &+= 1
      end

      return {M0Node.new(zstr.to_s, cpos, _idx), _idx + size}
    end

    nodes = [] of MtNode

    while true
      node, _idx = self.parse(iter, _idx)
      nodes << node

      char = iter.next.as(Char)
      break if char == ')'
      iter.next if char == ' '
    end

    # pp nodes

    case cpos
    when "NP" then return {NpNode.new(nodes, cpos, from), _idx}
    when "VP" then return {VpNode.new(nodes, cpos, from), _idx}
    end

    case nodes.size
    when 1 then {M1Node.new(nodes[0], cpos, from), _idx}
    when 2 then {M2Node.new(nodes[0], nodes[1], cpos, from), _idx}
      # when 3 then {M3Node.new(nodes[0], nodes[1], nodes[2], cpos, from), _idx}
    else {MxNode.new(nodes, cpos, from), _idx}
    end
  end

  # pp parse("(NP\n  (QP (CD 很多))\n  (DNP (NP (NN 医学) (NN 领域) (PU 、) (NN 制药) (NN 领域)) (DEG 的))\n  (NP (NN 专家)))")
end
