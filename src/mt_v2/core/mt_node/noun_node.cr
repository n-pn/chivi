require "./_node_base"

# ameba:disable Style/TypeNames
class M2::NP_Node
  include MtNode
  include MtSeri

  @detm : MtNode | Nil = nil
  @noun : MtNode | Array(MtNode)

  @ptag = :NP

  def initialize(@noun : MtNode)
    @size = noun.size
    @cost = noun.cost
  end

  def initialize(@noun : Array(MtNode))
    @size = noun.sum(&.size)
    @cost = noun.sum(&.cost)
  end

  def each(&)
    noun = @noun

    if noun.is_a?(MtNode)
      yield noun
    else
      noun.each { |node| yield node }
    end
  end

  def to_txt(io : IO, apply_cap : Bool) : Bool
    @noun.to_txt(io, apply_cap)
  end

  def to_mtl(io : IO, apply_cap : Bool) : Bool
    @noun.to_txt(io, apply_cap)
  end
end
