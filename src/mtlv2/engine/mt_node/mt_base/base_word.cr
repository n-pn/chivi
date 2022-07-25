require "./_abstract"

module MtlV2::MTL
  class BaseWord < BaseNode
    property key : String = ""
    property val : String = ""

    def initialize(@key = "", @val = @key, @tab = 0, @idx = 0)
    end

    def initialize(term : V2Term, val : String? = nil)
      @key = term.key
      @key = val || term.vals[0]
    end

    def dup!(idx : Int32, tab : Int32 = 1) : BaseNode
      res = self.dup
      res.idx = idx
      res.tab = tab
      res
    end

    def apply_cap!(cap : Bool = false) : Bool
      @val = QtranUtil.capitalize(@val) if cap
      false
    end

    def to_txt(io : IO) : Nil
      io << @val
    end

    def to_mtl(io : IO) : Nil
      io << @val << 'ǀ' << @tab << 'ǀ' << @idx << 'ǀ' << @key.size
    end

    def inspect(io : IO = STDOUT, pad = -1) : Nil
      io << " " * pad if pad > 0
      io << "[#{@key}/#{@val}/#{self.klass}/#{@tab}/#{@idx}]"
      io << '\n' if pad >= 0
    end
  end
end
