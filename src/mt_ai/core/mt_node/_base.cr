module AI::MtNode
  property ptag = ""
  property attr = ""
  getter _idx = 0

  abstract def z_each(& : MtNode ->)
  abstract def v_each(& : MtNode ->)

  def inspect(io : IO)
    io << '(' << @ptag
    io << '-' << @attr unless @attr.empty?
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
