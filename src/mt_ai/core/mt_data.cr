require "http/client"
require "./mt_node/*"
require "../data/mt_dict"

# references:
# - https://hanlp.hankcs.com/docs/annotations/pos/ctb.html
# - https://hanlp.hankcs.com/docs/annotations/constituency/ctb.html

class AI::MtData
  getter root : MtNode

  delegate zstr, to: @root

  def initialize(@root : MtNode)
    @translated = false
  end

  def translate!(dict : MtDict, coarse : Bool = true)
    return if @translated
    @translated = true

    if coarse
      @root.tl_phrase!(dict)
    else
      @root.tl_word!(dict)
    end
  end

  def to_txt(apply_cap = true, pad_space = false)
    String.build { |io| to_txt(io, apply_cap, pad_space) }
  end

  def to_txt(io : IO, apply_cap : Bool, pad_space : Bool)
    @root.to_txt(io, apply_cap, pad_space)
  end

  def inspect(io : IO)
    @root.inspect(io)
  end

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
      node, _idx = self.do_parse_con_data(iter, _idx)
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

  # def parse_file(input : String)
  #   url = "localhost:5555/mtl/electra_small/file?file=#{input}"
  #   HTTP::Client.get(url) do |res|
  #     raise "invalid: #{res.body_io.gets_to_end}" unless res.status.success?
  #     # puts File.read(input.sub(".txt", ".con"))
  #   end
  # end

  # # def parse_line(input : String)
  # #   url = "localhost:5555/con/rand"

  # #   HTTP::Client.post(url, body: input) do |res|
  # #     puts res.body_io.gets_to_end
  # #   end
  # # end
  # time = Time.measure do
  #   # parse_line " “浅川同学。”一花笑吟吟道，“昨天下午的提议你考虑的怎么样了？” "
  #   parse_file "/2tb/tmp.chivi/texts/1-f3mh03-1.txt"
  # end
end
