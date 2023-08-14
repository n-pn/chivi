require "./chinfo"
require "./wn_seed"

class WN::Zctext
  def initialize(@seed : Wnseed, @chap : Chinfo)
  end

  def get_ztext!
    ""
  end

  def get_cksum!(uname : String, _mode = 0)
    return "" if _mode < 0
    return force_regen! if _mode > 1
    return @chap.cksum unless @chap.cksum.empty?

    # TODO: recaculate check sum
    @chap.cksum
  end

  def force_regen!
    # TODO
    ""
  end
end
