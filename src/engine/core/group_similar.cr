module Engine::Core
  def group_similar(input : Tokens) : Tokens
    output = Tokens.new
    idx = 0

    while idx < input.size
      cur = input[idx]
      jdx = idx + 1

      if cur.dic == 0 && similar?(cur.key)
        while tok = input[jdx]?
          break unless tok.dic == 0 && similar?(tok.key)
          cur.key += tok.key
          cur.val += tok.val
          jdx += 1
        end
      end

      output << cur
      idx = jdx
    end

    output
  end

  private def similar?(key : String)
    key =~ /[\w-\/.?%=]/
  end

  # TODO: handle weblinks?
  private def similar?(current : Token, pending : Token) : Bool
    return false if pending.dic > 0
    a = current.key[0]
    b = pending.key[0]
    return true if a == b
    a.alphanumeric? && b.alphanumeric?
  end
end
