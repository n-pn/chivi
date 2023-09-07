require "./mt_prop"

class M2::MtTerm
  getter key : String
  getter val : String
  getter dic : Int8 = 0
  getter prio : Int32 = 3

  def initialize(@key, @val, @dic, @prio = 3)
  end

  def print_val(io : IO, prop : MtAttr, apply_cap : Bool = val) : Bool
    if prop.cap_relay? # for punctuation
      io << @val
      apply_cap || prop.cap_after?
    elsif apply_cap
      io << @val[0].upcase << @val[1..] unless @val.empty?
      prop.cap_after?
    else
      io << @val
      attr.cap_after?
    end
  end

  def val_capped(io : IO)
    io << @val[0].upcase << @val[1..] unless @val.empty?
  end
end
