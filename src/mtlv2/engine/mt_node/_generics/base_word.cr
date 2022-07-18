require "./base_node"

module MtlV2::MTL
  class BaseWord < BaseNode
    property lbl : Int32 = 0
    property key : String = ""
    property val : String = ""

    def initialize(@key = "", @val = @key, @lbl = 0, @idx = 0)
    end

    def initialize(term : V2Term, val : String? = nil)
      @key = term.key
      @key = val || term.vals[0]
    end

    def copy!(idx : Int32, lbl : Int32 = 1) : BaseNode
      res = self.dup
      res.idx = idx
      res.lbl = lbl
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
      io << @val << 'ǀ' << @lbl << 'ǀ' << @idx << 'ǀ' << @key.size
    end

    def inspect(io : IO = STDOUT, pad = -1) : Nil
      io << " " * pad if pad >= 0
      tag = self.class.to_s.sub("MtlV2::MTL::", "")
      io << "[#{@key}/#{@val}/#{tag}/#{@lbl}/#{@idx}]"
      io << '\n' if pad >= 0
    end
  end
end
