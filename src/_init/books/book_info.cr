class BookInfo
  getter file : String

  FIELDS = [] of String

  macro property(name)
    {% FIELDS << name.var.id.stringify %}

    @{{name}}

    def {{name.var.id}} : {{name.type}}
      @{{name.var.id}}
    end

    def {{name.var.id}}=(value : {{name.type}})
      @{{name.var.id}} = value
    end

    def set_{{name.var.id}}(value : {{name.type}})
      return if @{{name.var.id}} == value
      File.open(@file, "a") { |io| serialize(io, {{name.var.stringify}}, value) }
      @{{name.var.id}} = value
    end

    {% if name.type.stringify == "String" %}
      def {{name.var.id}}=(value : Array(String))
        @{{name.var.id}} = value[0]
      end
    {% elsif name.type.stringify == "Int32" %}
      def {{name.var.id}}=(value : Array(String))
        @{{name.var.id}} = value[0].to_i
      end
    {% elsif name.type.stringify == "Int64" %}
      def {{name.var.id}}=(value : Array(String))
        @{{name.var.id}} = value[0].to_i64
      end
    {% end %}
  end

  property btitle : String = ""
  property author : String = ""

  property genres : Array(String) = [] of String
  property bintro : Array(String) = [] of String
  property bcover : String = ""

  property status : Int32 = 0
  property mftime : Int64 = 0_i64

  property last_chidx : Int32 = 0
  property last_schid : String = ""

  def initialize(@file, reset = false)
    Dir.mkdir_p(File.dirname(@file))
    load!(file) if !reset && File.exists?(file)
  end

  def load!(file : String = @file)
    File.each_line(file) do |line|
      rows = line.split('\t')
      add_info(rows[0], rows[1..]) if rows.size > 1
    end
  end

  def add_info(type : String, value : Array(String))
    {% begin %}
    case type
    {% for name in FIELDS %}
    when {{name.id.stringify}} then self.{{name.id}} = value
    {% end %}
    end
    {% end %}
  end

  def serialize(io : IO, type : String, value : Object)
    io << type << '\t'

    if value.is_a?(Enumerable)
      value.join(io, '\t')
    else
      io << value
    end

    io << '\n'
  end

  def save!
    File.open(@file, "w") do |io|
      {% for name in FIELDS %}
        serialize(io, "{{name.id}}", @{{name.id}})
      {% end %}
    end
  end
end

# test = BookInfo.new("tmp/book_info.tsv")
# # test.set_btitle("btitle 2")
# # test.set_author("author")
# # test.btitle = ["btitle!!"]
# pp test
# test.save!
