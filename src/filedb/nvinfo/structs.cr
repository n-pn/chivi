require "json"

module CV::Nvinfo
  struct BasicInfo
    include JSON::Serializable

    getter bhash : String
    getter bslug : String

    getter btitle : Array(String)
    getter author : Array(String)
    getter genres : Array(String)

    getter bcover : String?
    getter voters : Int32
    getter rating : Int32

    def initialize(@bhash, @bslug, @btitle, @author, @genres, @bcover, @voters, @rating)
    end

    def inspect(io : IO)
      to_pretty_json(io)
    end
  end

  struct ExtraInfo
    include JSON::Serializable

    getter chseed : Hash(String, String)
    getter bintro : Array(String)
    getter status : Int32

    getter yousuu : String?
    getter origin : String?
    getter update_tz : Int64

    def initialize(@chseed, @bintro, @status, @yousuu, @origin, @update_tz)
    end

    def inspect(io : IO)
      to_pretty_json(io)
    end
  end
end
