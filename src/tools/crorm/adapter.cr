require "db"
require "sqlite3"
require "colorize"

class Crorm::Adapter
  def initialize(@url : String)
  end

  # forward_missing_to db

  def open(&)
    DB.open(@url) { |db| yield db }
  end

  def transaction
    open do |db|
      db.transaction { |tx| yield tx.connection }
    end
  end

  def log(query : String, elapsed_time : Time::Span, params = [] of String) : Nil
    Log.debug { [query, params, elapsed_time.total_seconds] }
  end

  # remove all rows from a table and reset the counter on the id.
  def clear(table : String)
    statement = "DELETE FROM #{table}"
    elapsed_time = Time.measure { open(&.exec(statement)) }
    log(statement, elapsed_time)
  end

  QUOTING_CHAR  = '"'
  LAST_VAL_STMT = "SELECT LAST_INSERT_ROWID()"

  # quotes table and column names
  def quote(name : String) : String
    String.build { |io| quote(io, name) }
  end

  def query(query_str : String, args : Enumerable(DB::Any), as_class : Class)
    open do |db|
      db.query query_str, args, as: as_class
    end
  end

  # :ditto:
  def quote(io : IO, name : String) : IO
    io << QUOTING_CHAR << name << QUOTING_CHAR
  end

  def insert_stmt(table : String, fields : Array(String), values : Array(DB::Any))
    String.build do |stmt|
      stmt << "INSERT INTO " << table << " ("

      fields.each_with_index do |field, i|
        stmt << ", " if i > 0
        stmt << field
      end

      stmt << ") VALUES ("

      fields.size.times do |i|
        stmt << ", " if i > 0
        stmt << "?"
      end

      stmt << ")"
    end
  end

  def update_stmt(fields : Array(String), table : String, where_clause : String? = nil)
    String.build do |stmt|
      stmt << "UPDATE " << table << " SET "

      fields.each_with_index do |field, i|
        stmt << ", " if i > 0
        stmt << field << " = ?"
      end

      stmt << " WHERE " << where_clause if where_clause
    end
  end

  def insert(table : String, fields : Array(String), values : Array(DB::Any), lastval : Bool) : Int64
    statement = insert_stmt(table, fields, values)
    do_insert(statement, values, lastval: lastval)
  end

  # This will update a row in the database.
  def update(table : String, fields : Array(String), values : Array(DB::Any), where_clause : String? = nil)
    statement = update_stmt(fields, table, where_clause)
    elapsed_time = Time.measure { open(&.exec(statement, args: values)) }
    log statement, elapsed_time, values
  end

  def upsert_stmt(fields : Array(String), where_clause : String? = nil)
    String.build do |stmt|
      fields.each_with_index do |field, i|
        stmt << ", " if i > 0
        stmt << field << " = " << yield(field)
      end

      stmt << " WHERE " << where_clause if where_clause
    end
  end

  # Insert or update
  def upsert(cnn : DB::Connection | DB::Database, table : String,
             fields : Array(String), values : Array(DB::Any),
             conflict_stmt : String, where_clause : String?, update_stmt : String)
    upsert(cnn, table, fields, values, conflict_stmt) { update_stmt }
  end

  # :ditto:
  def upsert(cnn : DB::Connection | DB::Database,
             table : String, fields : Array(String), values : Array(DB::Any),
             conflict_stmt : String, where_clause : String? = nil, &block) : Nil
    statement = String.build do |stmt|
      stmt << insert_stmt(table, fields, values)
      stmt << " ON CONFLICT #{conflict_stmt} DO UPDATE SET " << yield
      stmt << " WHERE " << where_clause if where_clause
    end

    cnn.exec(statement, args: values)
  end

  def do_insert(statement : String, values : Array(DB::Any), lastval = false)
    last_id = -1_i64

    elapsed_time = Time.measure do
      open do |db|
        db.exec(statement, args: values)
        last_id = db.scalar(LAST_VAL_STMT).as(Int64) if lastval
      end
    end

    log statement, elapsed_time, values
    last_id
  end

  def scalar(table : String, select_stmt : String, params = [] of DB::Any, query_stmt : String? = nil)
    statement = String.build do |stmt|
      stmt << "SELECT " << select_stmt << " FROM " << table
      stmt << " WHERE " << query_stmt if query_stmt
    end

    output = nil
    elapsed_time = Time.measure do
      output = open(&.scalar(statement, args: params))
    end

    log statement, elapsed_time
    output
  end

  def first(table : String, query_stmt : String, params, selects = [] of String)
    statement = String.build do |stmt|
      stmt << "SELECT "
      if selects.empty?
        stmt << "*"
      else
        selects.join(stmt, ", ")
      end

      stmt << " FROM " << table << " WHERE " << query_stmt
    end

    model = nil
    elapsed_time = Time.measure do
      open do |db|
        db.query(statement, args: params) { |rs| model = yield(rs).first? }
      end
    end

    log statement, elapsed_time
    model
  end
end
