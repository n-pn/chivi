require "json"

module BaseModel
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

  macro included
    include JSON::Serializable

    @[JSON::Field(ignore: true)]
    getter changes = 0

    def changed?
      @changes > 0
    end
  end
end
