require "./mt_node"

module SP::SpNers
  extend self

  enum Kind
    Int; Str; Url; Mix; Err

    def is_url?
      value <= Url.value
    end

    def is_mix?
      value <= Str.value
    end

    def map_prop(prop : MtProp)
      case self
      when .mix? then prop
      when .url? then MtProp::None
      else            MtProp::Content
      end
    end

    def self.map(node : MtNode)
      return Err if node.val.blank?

      case node.prop
      when .content?  then Err
      when .int_part? then Int
      when .str_part? then Str
      else                 Mix
      end
    end

    def self.map(node : MtNode, prev : self)
      case node.prop
      when .content?  then Err
      when .int_part? then prev.is_url? ? prev : Err
      when .str_part? then prev.is_url? ? prev : Err
      when .url_part? then prev.mix? ? prev : Url
      else                 prev.mix? ? prev : Err
      end
    end
  end

  def scan_all(nodes : Array(MtNode), index = 0)
    output = Array(MtNode?).new(size: nodes.size, value: nil)

    while index < nodes.size
      if node = scan_best(nodes, index)
        output[index] = node
        index &+= node.size
      else
        index &+= 1
      end
    end

    output
  end

  private def scan_best(nodes : Array(MtNode), index = 0)
    node = nodes.unsafe_fetch(index)
    kind = Kind.map(node)
    return if kind.err?

    prop = node.prop

    while index < nodes.size
      index &+= 1

      curr = nodes.unsafe_fetch(index)
      kind = Kind.map(curr, kind)

      break if kind.err?
      prop = kind.map_prop(prop)
    end

    size = index &- node.idx
    return unless size > 1

    val = String.build do |str|
      node.idx.upto(index &- 1) do |i|
        str << nodes.unsafe_fetch(i).val
      end
    end

    MtNode.new(val, idx: node.idx, size: size, prop: prop)
  end
end
