require "json"
require "colorize"

module JsonData
  macro included
    include JSON::Serializable

    @[JSON::Field(ignore: true)]
    getter changes = 0

    # check if object is modifified
    def changed?(min : Int = 0)
      @changes > min
    end

    # reset changes count and return old count value
    def reset_changes! : Int32
      @changes, returning = 0, @changes
    end
  end

  macro property(name)
    @{{name}}

    def {{name.target.id}}
      @{{name.target.id}}
    end

    def {{name.target.id}}=(value)
      return if @{{name.target.id}} == value

      @changes += 1
      @{{name.target.id}} = value
    end
  end
end
