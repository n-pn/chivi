# require "sqlite3"

module Crorm
  class Field(T)
    struct Blank; end

    BLANK = Blank.new

    @value : T | Blank
    @old_value : T | Blank

    def initialize(@value : T | Blank = BLANK)
      @old_value = value
    end

    def self.from_rs(rs : DB::ResultSet)
      new(rs.read(T))
    end

    def changed?
      @value != @old_value
    end

    def value=(@value : T)
    end

    def revert
      @value = @old_value
    end

    def value : T
      defined? ? @value.as(T) : raise "Undefined"
    end

    def defined?
      @value.is_a?(T)
    end
  end

  module Model
    macro column(name)
      @[DB::Field(key: {{ name.var.stringify }}, converter: Crorm::Field({{name.type}}))]
      {% if value = name.value %}
        @{{name.var}} : Crorm::Field({{name.type}}) = Crorm::Field({{name.type}}).new({{value}})
      {% else %}
        @{{name.var}} : Crorm::Field({{name.type}}) = Crorm::Field({{name.type}}).new()
      {% end %}

      def {{name.var}}_column : Crorm::Field({{name.type}})
        @{{name.var}}
      end

      def {{name.var}} : {{name.type}}
        @{{name.var}}.value
      end

      def {{name.var}}=(value : {{name.type}})
        @{{name.var}}.value = value
      end
    end

    def changed?
      {% for ivar in @type.instance_vars %}
        {% if ivar.is_a?(Field) %}
          return true if {{ivar.name.id}}.changed?
        {% end %}
      {% end %}

      false
    end

    def changes(on_create = false) : Hash(String, DB::Any)
      output = {} of String => DB::Any

      {% for ivar in @type.instance_vars %}
        {% if ivar.type < Crorm::Field %}
          if @{{ivar.name.id}}.changed?
            {% column_name = ivar.name.stringify %}
            output[{{column_name}}] = @{{ivar.name.id}}.value
          end
        {% end %}
      {% end %}

      return output if output.empty?

      {% if @type.has_method?(:created_at) %}
        if on_create && !@created_at.changed?
          output["created_at"] = self.created_at = Time.utc.to_unix
        end
      {% end %}

      {% if @type.has_method?(:updated_at) %}
        unless @updated_at.changed?
          output["updated_at"] = self.updated_at = Time.utc.to_unix
        end
      {% end %}

      output
    end

    def attributes
      output = {} of String => DB::Any

      {% for ivar in @type.instance_vars %}
        {% if ivar.type < Crorm::Field %}
          {% column_name = ivar.name.stringify %}
          output[{{column_name}}] = @{{ivar.name.id}}.value
        {% end %}
      {% end %}

      output
    end

    macro included
      include ::DB::Serializable

      def initialize
      end

    end
  end

  class Repo(T)
    getter db : DB::Database
    getter file : String

    def initialize(@file, @table : String)
      @db = DB.open("sqlite3:#{file}")
    end

    def count
      @db.scalar "select count(*) from #{@table}"
    end

    def find(query : String) : T?
      @db.query "select * from #{@table} where #{query} limit 1" do |rs|
        T.from_rs(rs).first?
      end
    end

    def query(query : String) : Array(T)
      @db.query "select * from #{@table} where #{query}" do |rs|
        T.from_rs(rs)
      end
    end

    def upsert(changes : Hash(String, DB::Any), cnn = @db, conflict = "id")
      columns = changes.keys
      holders = Array(String).new(size: columns.size, value: "?")
      updates = columns.map { |x| "#{x} = excluded.#{x}" }

      sql = <<-SQL
        insert or replace into #{@table} (#{columns.join(", ")})
        values (#{holders.join(", ")})
        on conflict(#{conflict}) do update set #{updates.join(", ")};
      SQL

      rs = cnn.exec(sql, args: changes.values)
      rs.last_insert_id
    end
  end
end

# class Test
#   include Crorm::Model

#   column id : Int64
#   column type : String = ""
# end

# test = Test.new
# test.type = "123"

# pp test.type
# puts test.changes
