# require "sqlite3"
require "./adapter"

module Crorm::Query(Model)
  @adapter : Crorm::Adapter

  def query(clause = "", params = [] of DB::Any, &block)
    adapter.open { |db| yield db.query(clause, args: params) }
  end
end

# module Crorm
#   class Repo(T)
#     getter db : DB::Database
#     getter file : String

#     def initialize(@file, @table : String)
#       @db = DB.open("sqlite3:#{file}")
#     end

#     def count
#       @db.scalar "select count(*) from #{@table}"
#     end

#     def upsert(changes : Hash(String, DB::Any), cnn = @db, conflict = "id")
#       columns = changes.keys
#       holders = Array(String).new(size: columns.size, value: "?")
#       updates = columns.map { |x| "#{x} = excluded.#{x}" }

#       sql = <<-SQL
#         insert or replace into #{@table} (#{columns.join(", ")})
#         values (#{holders.join(", ")})
#         on conflict(#{conflict}) do update set #{updates.join(", ")};
#       SQL

#       rs = cnn.exec(sql, args: changes.values)
#       rs.last_insert_id
#     end
#   end
# end
