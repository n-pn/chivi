require "./punct"

module MtlV2
  class TitleOp < PunctNode
    def fold! : BaseNode
      end_key = match_title_end(@key[0]?)
      tail = self

      list = BaseList.new("")

      while tail = tail.succ?
        break if tail.tag.titlecl? && tail.key[0]? == end_key
        list.add_tail(tail)
      end

      list = list.fold!
      return self unless tail && tail != head.succ?

      BtitleForm.new(head, tail, list).fold!
    end

    private def match_title_end(char : Char)
      case char
      when '《' then '》'
      when '〈' then '〉'
      when '⟨' then '⟩'
      when '<' then '>'
      else          char
      end
    end
  end

  class BtitleForm < Btitle
    def initialize(@head : TitleOp, @tail : TitleCl, @body : BaseList)
      @key = ""
      @val = ""

      @dic = 0
      @idx = @head.idx

      @tag = PosTag::Btitle

      self.set_prev(@head.prev?)
      self.set_succ(@tail.succ?)
    end

    def to_s(io : IO)
      @head.to_s(io)
      @body.to_s(io)
      @tail.to_s(io)
    end
  end
end
