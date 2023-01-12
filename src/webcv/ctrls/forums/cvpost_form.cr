require "json"

struct CV::CvpostForm
  include JSON::Serializable

  getter title : String
  getter labels : String

  getter body_input : String
end
