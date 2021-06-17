require "clear"

# initialize a pool of database connection:
DB_USER = ENV["DB_USER"]? || "postgres"
DB_PASS = ENV["DB_PASS"]? || "postgres"
DB_NAME = ENV["DB_NAME"]? || "chivi"

Clear::SQL.init("postgres://#{DB_USER}:#{DB_PASS}@localhost/#{DB_NAME}?initial_pool_size=5&retry_attempts=2")

class Clear::Expression
  def self.safe_literal(x : Enumerable(AvailableLiteral)) : String
    {"ARRAY[", x.map { |item| self.safe_literal(item) }.join(", "), "]"}.join
  end
end
