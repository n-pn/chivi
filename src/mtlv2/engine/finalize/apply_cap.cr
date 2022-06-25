module MtlV2::AST
  class BaseNode
    def capitalize!(cap : Bool = false) : Bool
      if cap
        res = String::Builder.new(@val.size)
        nocap = true

        @val.each_char do |char|
          if nocap && char.alphanumeric?
            res << char.upcase
            nocap = false
          else
            res << char
          end
        end

        @val = res.to_s
      end

      false
    end
  end

  class BaseList
    def capitalize!(cap : Bool = true)
      node = @head

      while node
        cap = node.capitalize!(cap)
        node = node.succ?
      end

      cap
    end
  end

  class Fixstr
    def capitalize!(cap : Bool = false) : Bool
      false
    end
  end

  class Punct

    # private def cap_after_punct?(prev = false) : Bool
    #   case @tag
    #   when .quoteop?, .exmark?, .qsmark?,
    #        .pstop?, .colon?, .middot?, .titleop?
    #     true
    #   when .pdeci?   then @prev.try { |x| x.ndigit? || x.litstr? } || prev
    #   when .brackop? then true
    #     # when .parenop? then  prev
    #   else prev
    #   end
    # end
  end
end
