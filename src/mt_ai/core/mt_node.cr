require "./mt_node/*"

module AI::MtNode
  # references:
  # - https://hanlp.hankcs.com/docs/annotations/pos/ctb.html
  # - https://hanlp.hankcs.com/docs/annotations/constituency/ctb.html

  def self.parse(input : String, cleaned = false)
    input = input.gsub(/\n[\t\s]+/, " ") unless cleaned
    puts input

    iter = input.each_char
    iter.next # remove first '(' character
    node, _idx = parse(iter, _idx: 0)

    node
  end

  private def self.parse(iter, _idx = 0)
    sbuf = String::Builder.new

    while char = iter.next
      break if char == ' '
      sbuf << char
    end

    ptag, _, attr = sbuf.to_s.partition('-')

    char = iter.next.as(Char)

    if char != '(' # core term
      zstr = String::Builder.new
      zstr << char

      while char = iter.next.as(Char)
        break if char == ')'
        zstr << char
        _idx &+= 1
      end

      return {M0Node.new(zstr.to_s, ptag, attr, _idx), _idx}
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

    case ptag
    when "NP" then return {NpNode.new(nodes, ptag, attr, _idx), _idx}
    when "VP" then return {VpNode.new(nodes, ptag, attr, _idx), _idx}
    end

    case nodes.size
    when 1 then {M1Node.new(nodes[0], ptag, attr, _idx), _idx}
    when 2 then {M2Node.new(nodes[0], nodes[1], ptag, attr, _idx), _idx}
    when 3 then {M3Node.new(nodes[0], nodes[1], nodes[2], ptag, attr, _idx), _idx}
    else        {MxNode.new(nodes, ptag, attr, _idx), _idx}
    end
  end

  # pp parse("(NP\n  (QP (CD 很多))\n  (DNP (NP (NN 医学) (NN 领域) (PU 、) (NN 制药) (NN 领域)) (DEG 的))\n  (NP (NN 专家)))")
end