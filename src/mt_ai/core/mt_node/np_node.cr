require "./_base"

class AI::NpNode
  include MtNode

  getter data = [] of MtNode

  def initialize(input : Array(MtNode), @ptag, @attr, @_idx)
    input.reverse_each do |node|
      case node.ptag
      when "QP" then @data.unshift(node)
      when "DNP"
        node.attr.includes?("HEAD") ? @data.unshift(node) : @data.push(node)
      else
        @data << node
      end
    end
  end

  def each(&)
    @data.each { |node| yield node }
  end

  def last
    @data.last
  end
end
