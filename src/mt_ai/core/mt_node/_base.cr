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
