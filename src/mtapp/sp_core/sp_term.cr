require "../shared/fmt_flag"
require "./sp_defn"

struct MT::SpTerm
  getter val : String
  getter len : Int32
  getter dic : Int32
  getter fmt : FmtFlag

  def self.new(zstr : String, vstr : String)
    new(vstr, zstr.size)
  end

  def self.new(char : Char)
    char = ',' if char == '､'
    new(char.to_s, len: 1, dic: 0, fmt: FmtFlag.detect(char))
  end

  def initialize(@val, @len, @dic = 1, @fmt = FmtFlag.auto_detect(val))
  end
end
