require "../ai_dict"

module MT::AiNode
  getter zstr : String = ""

  getter cpos : String = ""
  getter ipos : Int8 = 0_i8

  getter vstr : String = ""
  getter attr : MtAttr = MtAttr::None

  getter dnum : Int8 = -1_i8
  getter _idx : Int32 = 0

  abstract def z_each(& : AiNode ->)
  abstract def v_each(& : AiNode ->)
  abstract def first
  abstract def last

  def tl_whole!(dict : AiDict)
    dict.get?(@zstr, @ipos).try { |term| self.set_term!(term) }
  end

  def find_by_ipos(ipos : Int8)
    z_each do |node|
      return node if node.ipos == ipos
      unless node.is_a?(M0Node)
        found = node.find_by_ipos(ipos)
        return found if found
      end
    end
  end

  def find_by_ipos(*ipos : Int8)
    z_each do |node|
      return node if node.ipos.in?(*ipos)

      unless node.is_a?(M0Node)
        found = node.find_by_ipos(*ipos)
        return found if found
      end
    end
  end

  def set_term!(term : MtTerm) : Nil
    @vstr = term.vstr
    @attr |= term.attr
    @dnum = term.dnum
  end

  def set_vstr!(@vstr : String, @dnum : Int8 = MtDnum::Fixture_2.to_i8) : Nil
  end

  def has_attr?(attr : MtAttr)
    @attr.includes?(attr)
  end

  def add_attr!(attr : MtAttr)
    @attr |= attr
  end

  def off_attr!(attr : MtAttr)
    @attr &= ~attr
  end

  def same_attr?(other : self, attr : MtAttr)
    self.attr & other.attr & attr != MtAttr::None
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
    if @dnum >= 0
      io << ' ' unless @attr.undent?(und: und)
      @attr.render_vstr(io, @vstr, cap: cap, und: und)
    elsif self.is_a?(M0Node)
      raise "translation missing!"
    else
      self.v_each { |node| cap, und = node.to_txt(io, cap: cap, und: und) }
      {cap, und}
    end
  end

  def to_json(jb : JSON::Builder) : Nil
    jb.array do
      jb.string @cpos
      jb.number @_idx
      jb.number @zstr.size
      jb.string(@attr.none? ? "" : @attr.to_str)

      if @dnum >= 0 || self.is_a?(M0Node)
        jb.string @zstr
        jb.string @vstr
        jb.number @dnum
      else
        jb.array { self.v_each(&.to_json(jb)) }
      end
    end
  end
end
