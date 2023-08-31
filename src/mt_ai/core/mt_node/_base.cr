require "../../data/vp_pecs"

module AI::MtNode
  property cpos : String = ""
  # property attr : String = ""

  property vstr : String = ""
  property pecs : VpPecs = VpPecs::None
  property dpos : Int32 = 0

  getter _idx : Int32 = 0

  abstract def z_each(& : MtNode ->)
  abstract def v_each(& : MtNode ->)

  def inspect(io : IO)
    io << '(' << @cpos
    # io << ':' << @_idx
    inspect_inner(io)
    io << ')'
  end

  private def inspect_inner(io : IO)
    self.z_each do |node|
      io << ' '
      node.inspect(io)
    end
  end
end
