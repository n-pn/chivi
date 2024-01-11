require "../../_util/char_util"
require "../../_util/viet_util"
require "../../_util/time_util"
require "../../_util/text_util"

module SQ3Enum(T)
  def self.from_rs(rs : ::DB::ResultSet)
    T.from_value(rs.read(Int32))
  end

  def self.to_db(epos : T)
    epos.to_i
  end
end
