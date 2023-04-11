require "./ner_core/*"

class MT::NerCore
  @[Flags]
  struct Opts
    getter? enabled = false
    getter? persist = false

    def initialize(@enabled, @persist)
    end
  end

  def initialize(@dict : NerDict, @opts : Opts)
  end

  def fetch_all(chars : Array(Char), &)
    hash = gen_hash(chars)

    index = 0
    while index < chars.size
      data = hash[index]

      best_node = nil
      best_mark = EntMark::None

      data.sner.each do |mark, node|
        next if best_node && best_node.sum >= node.sum

        best_node = node
        best_mark = mark
      end

      if best_node
        yield index, best_node.sum, best_mark, best_node.get_value(best_mark)
        index &+= best_node.sum
      else
        index &+= 1
      end
    end
  end

  private def gen_hash(chars : Array(Char))
    hash = {} of Int32 => NerData

    (chars.size - 1).downto(0) do |index|
      curr = hash[index] = NerData.new

      @dict.fetch_all(chars, start: index) do |node|
        EntMark.each do |mark|
          curr.add_sner(mark, node) if node.sner?(mark)
        end

        succ = hash[index &+ node.sum]?

        EntMark.each do |mark|
          curr.add_ener(mark, node) if node.ener?(mark)
          next unless succ && (succ_node = succ.ener[mark]?)

          curr.add_ener(mark, NerNode.new(node, succ_node)) if node.iner?(mark)
          curr.add_sner(mark, NerNode.new(node, succ_node)) if node.bner?(mark)
        end
      end
    end

    hash
  end

  class_getter base : self do
    opts = Opts.new(enabled: true, persist: false)
    new(NerDict.base, opts)
  end
end
