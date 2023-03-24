require "../_base"

class CV::Memoir
  enum Type
    Dboard
    Dtopic
    Dtrepl
  end

  include JSON::Serializable

  @@table = "memoirs"

  property object_type : Type = :dboard
  property object_id : Int32 = 0

  property viuser_id : Int32 = 0

  property viewed_at : Int64 = 0 # last visited at
  property called_at : Int64 = 0 # get called in context

  property? track : Bool = false
  property? liked : Bool = false

  property extra : JSON::Any? = nil
end
