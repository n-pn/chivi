require "tabkv"

annotation TsvField
end

module TsvStore
  macro property(name)
    @[TsvField]
    @{{name}}

    def {{name.var.id}} : {{name.type}}
      @{{name.var.id}}
    end

    def {{name.var.id}}=(value : {{name.type}})
      return if value == @{{name.var.id}}
      @upds[{{name.var.id.stringify}}] = value.to_tsv.to_s
      @{{name.var.id}} = value
    end
  end

  getter file : String
  getter upds = {} of String => String

  def initialize(@file, reset : Bool = false)
    load!(file) if !reset && File.exists?(file)
  end

  def load!(file = @file)
    File.each_line(file) do |line|
      rows = line.split('\t')
      key = rows.shift
      add(key, rows) unless rows.empty?
    end
  end

  def add(key : String, val : Array(String)) : Bool
    {% begin %}
      case key
      {% for ivar in @type.instance_vars %}
        {% if ann = ivar.annotation(TsvField) %}
          when {{ivar.id.stringify}}
            value = {{ivar.type}}.from_tsv(val)
            return false if self.{{ivar.id}} == value
            self.{{ivar.id}} = value
        {% end %}
      {% end %}
      else return false
      end
    {% end %}

    true
  end

  def add!(key : String, val : Object)
    File.open(@file, "a") { |io| encode(io, key, val) }
  end

  private def encode(io : IO, key : String, val : Object)
    io << key << '\t' << val.to_tsv << '\n'
  end

  def atomic_save!
    return if @upds.empty?

    File.open(@file, "a") do |io|
      @upds.each do |key, value|
        io << key << '\t' << value << '\n'
      end
    end

    @upds.clear
  end

  def clean_save!(file = @file)
    File.open(file, "w") do |io|
      {% begin %}
        {% for ivar in @type.instance_vars %}
          {% if ann = ivar.annotation(TsvField) %}
            encode(io, {{ivar.id.stringify}}, {{ivar.id}})
          {% end %}
        {% end %}
      {% end %}
    end
  end
end

# module CV::TsvFile
#   {% TSV_FIELDS = [] of String %}

#   macro property
#     {% TSV_FIELDS << name.var.id.stringify %}

#     @{{name}}

#     def {{name.var.id}} : {{name.type}}
#       @{{name.var.id}}
#     end

#     def {{name.var.id}}=(value : {{name.type}})
#       @{{name.var.id}} = value
#     end

#     def set_{{name.var.id}}(value : {{name.type}})
#       return if @{{name.var.id}} == value
#       File.open(@file, "a") { |io| serialize(io, {{name.var.stringify}}, value) }
#       @{{name.var.id}} = value
#     end

#     {% if name.type.stringify == "String" %}
#       def {{name.var.id}}=(value : Array(String))
#         @{{name.var.id}} = value[0]
#       end
#     {% elsif name.type.stringify == "Int32" %}
#       def {{name.var.id}}=(value : Array(String))
#         @{{name.var.id}} = value[0].to_i
#       end
#     {% elsif name.type.stringify == "Int64" %}
#       def {{name.var.id}}=(value : Array(String))
#         @{{name.var.id}} = value[0].to_i64
#       end
#     {% end %}
#   end

#   def save!
#     File.open(@file, "w") do |io|
#       {% for name in TSV_FIELDS %}
#         serialize(io, "{{name.id}}", @{{name.id}})
#       {% end %}
#     end
#   end
# end
