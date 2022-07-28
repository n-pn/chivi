require "./mt_node/*"
require "./grammar/*"

module MtlV2::MTL
  class MtData
    getter head = PunctWord.new("")
    getter tail = PunctWord.new("")

    def initialize
      head.set_succ = tail
    end

    def concat(other : MtData) : self
      @tail.set_succ(other.head.succ?)
      @tail = other.tail
      self
    end

    def add_head(node : BaseWord)
      node.set_succ(@head.succ?)
      @head.set_succ(node)
    end

    def add_tail(node : BaseWord)
      node.set_prev(@tail.prev?)
      @tail.set_prev(node)
    end

    # @nests = [] of PunctWord
    # def add_node(node : BaseWord)
    #   if node.is_a?(OpenPunct) || node.is_a?(ClosePunct)
    #     @nests << node
    #     add_head(node)
    #   elsif @head.is_a?(MtTerm) && can_meld?(node, @head)
    #     @head.val = join_val(node, head)
    #     @head.key = node.key + head.key
    #     @head.idx = node.idx
    #     @head.dic = 0
    #   else
    #     succ = @head.succ?

    #     if fold = TlRule.fold_left!(right: @head, left: node)
    #       fold.fix_succ!(succ)
    #       @head = fold
    #     else
    #       add_head(node)
    #     end
    #   end
    # end

    ##########

    include MtSeri

    def each
      node = @head
      while node = node.succ?
        yield node
        break if node == @tail
      end
    end
  end
end
