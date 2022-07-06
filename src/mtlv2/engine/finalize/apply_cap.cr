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

  class BasePair
    def capitalize!(cap : Bool = true)
      @left.capitalize! if cap
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

  class PunctWord
    def capitalize!(cap : Bool = false) : Bool
      @flag.cap_after?
    end
  end
end
