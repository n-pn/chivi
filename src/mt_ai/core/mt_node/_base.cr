require "../../data/vp_pecs"
require "../../data/mt_dict"

module AI::MtNode
  getter cpos : String = ""
  getter pecs : VpPecs = VpPecs::None

  getter zstr : String = ""
  getter vstr : String = ""

  getter _dic : Int32 = 0
  getter _idx : Int32 = 0

  abstract def z_each(& : MtNode ->)
  abstract def v_each(& : MtNode ->)

  def set_tl!(found : Tuple(String, VpPecs, Int32)) : Nil
    @vstr, @pecs, @_dic = found
  end

  def set_tl!(@vstr, @pecs : VpPecs = VpPecs::None, @_dic : Int32 = 1) : Nil
  end

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

  def to_txt(io : IO, apply_cap : Bool, pad_space : Bool)
    if @_dic > 0 || self.is_a?(M0Node)
      io << ' ' if pad_space && !(@pecs.void? || @pecs.nwsl?)
      apply_cap, pad_space = self.render_vstr(io, apply_cap, pad_space)
    else
      self.v_each do |node|
        apply_cap, pad_space = node.to_txt(io, apply_cap, pad_space)
      end
    end

    {apply_cap, pad_space}
  end

  private def render_vstr(io : IO, apply_cap : Bool, pad_space : Bool)
    case
    when @pecs.void?
      # do nothing
    when @pecs.capx?
      io << @vstr
    when apply_cap
      @vstr.each_char_with_index { |c, i| io << (i == 0 ? c.upcase : c) }
      apply_cap = @pecs.capr?
    else
      io << @vstr
      apply_cap = @pecs.capr?
    end

    pad_space = !@pecs.nwsr? unless @pecs.void?
    {apply_cap, pad_space}
  end
end
