class Amber::Validators::Params
  def fetch_str(name : String | Symbol, df = "") : String
    self[name]? || df
  end

  def fetch_str(name : String, &block : -> String) : String
    self[name]? || yield
  end

  def fetch_int(name : String | Symbol, min = 0, max = Int32::MAX) : Int32
    val = self[name]?.try(&.to_i?) || 0
    val < min ? min : (val > max ? max : val)
  end

  def read_i8(name : String, df = 0_i8)
    self[name]?.try(&.to_i8?) || df
  end

  def read_i16(name : String, min : Int16 = 0_i16) : Int16
    val = self[name]?.try(&.to_i16?) || return min
    val < min ? min : val
  end

  def read_i16(name : String, min : Int16, max : Int16) : Int16
    val = self[name]?.try(&.to_i16?) || return min
    val < min ? min : (val > max ? max : val)
  end

  def fetch_int(name : String | Symbol, &block : -> Int32) : Int32
    self[name]?.try(&.to_i?) || yield
  end

  def page_info(min = 1, max = 100) : Tuple(Int32, Int32, Int32)
    pgidx = fetch_int("pg", min: 1)
    limit = fetch_int("lm", min, max)
    {pgidx, limit, limit &* (pgidx - 1)}
  end

  def fetch_i64(name : String)
    self[name]?.try(&.split('-', 2).first.to_i64?)
  end
end
