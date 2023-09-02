require "../ai_dict"

module MT::AiNode
  getter cpos : String = ""

  getter zstr : String = ""
  getter term : MtTerm? = nil

  getter _dic : Int32 = 0
  getter _idx : Int32 = 0

  abstract def z_each(& : AiNode ->)
  abstract def v_each(& : AiNode ->)

  def set_term!(@term, @_dic : Int32 = 1) : Nil
  end

  ###

  def inspect(io : IO)
    io << '('.colorize.dark_gray
    io << @cpos.colorize.bold
    # io << ':' << @_idx
    inspect_inner(io)
    io << ')'.colorize.dark_gray
  end

  private def inspect_inner(io : IO)
    self.z_each do |node|
      io << ' '
      node.inspect(io)
    end
  end

  ###

  def to_txt(io : IO, cap : Bool, pad : Bool)
    if term = @term
      io << ' ' if term.pad_space?(pad)
      term.to_str(io, cap, pad)
    elsif self.is_a?(M0Node)
      raise "translation missing!"
    else
      self.v_each { |node| cap, pad = node.to_txt(io, cap, pad) }
      {cap, pad}
    end
  end

  SEP = 'ǀ'

  def to_mtl(io : IO, cap : Bool, pad : Bool)
    if term = @term
      io << '\t' << ' ' if term.pad_space?(pad)
      io << '\t'

      cap, pad = term.to_str(io, cap, pad)
      io << SEP << @_dic << SEP << @_idx << SEP << term._len
      {cap, pad}
    elsif self.is_a?(M0Node)
      raise "translation missing!"
    else
      self.v_each { |node| cap, pad = node.to_mtl(io, cap, pad) }
      {cap, pad}
    end
  end
end
