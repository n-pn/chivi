module AI::MtNode
  property ptag = ""
  property attr = ""
  getter _idx = 0

  abstract def each(& : MtNode ->)

  def inspect(io : IO)
    io << '(' << @ptag
    io << '-' << @attr unless @attr.empty?
    inspect_inner(io)
    io << ')'
  end

  private def inspect_inner(io : IO)
    each do |node|
      io << ' '
      node.inspect(io)
    end
  end
end
