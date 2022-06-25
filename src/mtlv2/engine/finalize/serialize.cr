module MtlV2::AST
  class BaseNode
    def to_txt : String
      String.build { |io| to_txt(io) }
    end

    def to_txt(io : IO) : Nil
      io << @val
    end

    def to_mtl : String
      String.build { |io| to_mtl(io) }
    end

    def to_mtl(io : IO) : Nil
      io << "\t" << @val << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @key.size
    end

    def inspect(io : IO = STDOUT, pad = -1) : Nil
      io << " " * pad if pad >= 0

      tag = self.class.to_s.sub("MtlV2::AST::", "")
      io << "[#{@key}/#{@val}/#{tag}/#{@dic}/#{@idx}]"
      io << "\n" if pad >= 0
    end

    # def deep_inspect(io : IO = STDOUT, pad = 0) : Nil
    #   if body = @body
    #     io << " " * pad << "{" << @tag.tag << "/" << @dic << "}" << "\n"
    #     body.deep_inspect(io, pad &+ 2)
    #     io << " " * pad << "{/" << @tag.tag << "/" << @dic << "}" << "\n"
    #   else
    #     self.inspect(io, pad: pad)
    #   end

    #   @succ.try(&.deep_inspect(io, pad))
    # end
  end

  class Punct
    def to_mtl(io : IO) : Nil
      io << "\t" << @val << 'ǀ' << 0 << 'ǀ' << @idx << 'ǀ' << @key.size
    end
  end

  class Whitespace
    def to_mtl(io : IO) : Nil
      io << "\t" << @val
    end
  end

  class BaseList
    def to_txt(io : IO)
      return unless node = @head
      node.to_txt(io)

      while succ = node.succ?
        io << " " if node.space_after? || succ.space_before?
        succ.to_txt(io)
        node = succ
      end
    end

    def to_mtl : String
      return unless node = @head
      node.to_mtl(io)

      while succ = node.succ?
        io << " " if node.space_after? || succ.space_before?
        succ.to_mtl(io)
        node = succ
      end
    end

    def inspect(io : IO, pad = -1) : Nil
      return unless node = @head
      node.inspect(io, pad &+ 1)

      while succ = node.succ?
        io << " " if node.space_after? || succ.space_before?
        succ.inspect(io, pad &+ 1)
        node = succ
      end
    end
  end
end
