require "json"
require "uuid"
require "sqlite3"

module UUIDBlob
  def self.to_db(value : ::UUID) : DB::Any
    value.to_slice
  end

  def self.from_rs(rs : ::DB::ResultSet) : ::UUID?
    rs.read(Bytes | Nil).try { |b| ::UUID.new(b) }
  end
end
