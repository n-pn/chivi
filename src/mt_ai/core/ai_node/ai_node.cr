require "../ai_dict"

module MT::AiNode
  getter zstr : String = ""
  getter cpos : String = ""

  getter vstr : String = ""
  getter attr : MtAttr = MtAttr::None

  getter _dic : Int32 = -1
  getter _idx : Int32 = 0

  abstract def z_each(& : AiNode ->)
  abstract def v_each(& : AiNode ->)
  abstract def first
  abstract def last

  def find_by_cpos(cpos : String)
    z_each do |node|
      return node if node.cpos == cpos
      unless node.is_a?(M0Node)
        found = node.find_by_cpos(cpos)
        return found if found
      end
    end
  end

  def find_by_cpos(*cpos : String)
    z_each do |node|
      return node if node.cpos.in?(*cpos)

      unless node.is_a?(M0Node)
        found = node.find_by_cpos(*cpos)
        return found if found
      end
    end
  end

  def set_term!(term, @_dic : Int32 = 1) : Nil
    @vstr = term.vstr
    @attr |= term.attr
  end

  def set_vstr!(@vstr : String, @_dic : Int32 = 1) : Nil
  end

  def add_attr!(attr : MtAttr)
    @attr |= attr
  end

  def off_attr!(attr : MtAttr)
    @attr &= ~attr
  end

  ###

  def inspect(io : IO)
    io << '('.colorize.dark_gray
    io << @cpos.colorize.bold
    # io << ':' << @_idx
    inspect_inner(io)

    io << ' ' << @attr unless @attr.none?
    io << ')'.colorize.dark_gray
  end

  private def inspect_inner(io : IO)
    self.z_each do |node|
      io << ' '
      node.inspect(io)
    end
  end

  ###

  def to_txt(io : IO, cap : Bool, und : Bool)
    if @_dic >= 0
      io << ' ' unless @attr.undent?(und: und)
      @attr.render_vstr(io, @vstr, cap: cap, und: und)
    elsif self.is_a?(M0Node)
      raise "translation missing!"
    else
      self.v_each { |node| cap, und = node.to_txt(io, cap: cap, und: und) }
      {cap, und}
    end
  end

  SEP = 'ǀ'

  def to_mtl(io : IO, cap : Bool, und : Bool)
    if @_dic >= 0
      io << '\t' << ' ' unless @attr.undent?(und: und)
      io << '\t'

      cap, und = @attr.render_vstr(io, @vstr, cap: cap, und: und)
      io << SEP << @_dic << SEP << @_idx << SEP << @zstr.size
      {cap, und}
    elsif self.is_a?(M0Node)
      raise "translation missing!"
    else
      self.v_each { |node| cap, und = node.to_mtl(io, cap: cap, und: und) }
      {cap, und}
    end
  end
end
