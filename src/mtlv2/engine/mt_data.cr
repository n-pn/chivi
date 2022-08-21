require "./mt_node"
# require "./grammar/*"
require "./grammar/fold_left"

module MtlV2::MTL
  class MtData
    getter head : BaseNode
    getter tail : BaseNode

    def initialize
      @head = PunctWord.new("")
      @tail = PunctWord.new("")
      @head.set_succ(@tail)
    end

    def concat(other : MtData) : self
      other_head = other.head.succ

      other_head.set_prev(@tail.prev?)
      other.head.unlink!

      @tail.unlink!
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

    @nests = [] of PunctWord

    def fuse_head(head : BaseWord, node : BaseWord, joiner = "")
      head.key = node.key + head.key
      head.val = node.val + joiner + head.val
      head.idx = node.idx
      head
    end

    def add_node(node : PunctWord)
      if node.attr.start? || node.attr.close?
        @nests << node
        add_head(node)
      elsif (head = @head) && head.is_a?(PunctWord) && node.key[0] == head.key[0]
        fuse_head(head, node)
      else
        add_head(node)
      end
    end

    def add_node(node : NhanziWord)
      head = @head

      if !head.is_a?(NhanziWord)
        add_head(node)
      elsif head.key != "两" || node.key == "一"
        head.val = fix_hanzi_val(node, head)
        fuse_head(head, node, " ")
      else
        new_head = QuantiWord.new("两", val: "lượng", idx: head.idx)
        new_head.set_succ(head.succ?)
        node.set_succ(new_head)

        head.unlink!
        @head = node
      end
    end

    def add_node(node : BaseWord)
      add_head(node)
    end

    private def fix_hanzi_val(left : NhanziWord, right : NhanziWord)
      val = right.val

      case right.key[0]?
      when '五'
        left.key.ends_with?('十') ? val.sub("năm", "lăm") : val
      when '十'
        return val unless left.key =~ /[一二两三四五六七八九]$/
        val.sub("mười một", "mươi mốt").sub("mười", "mươi")
      when '零' then val.sub("linh", "lẻ")
      else          val
      end
    end

    def translate!
      # add anchor so the connection do not lost when @head replaced by other node
      fold_left!(@tail, @head)
    end

    def fold_left!(tail : BaseNode, head : BaseNode) : Nil
      while (tail = tail.prev?) && tail != head
        tail = MTL.fold_left!(tail, tail.prev)
      end
    end

    ##########

    include BaseSeri

    def each
      node = @head

      while (node = node.succ?) && node != @tail
        yield node
      end
    end
  end
end
