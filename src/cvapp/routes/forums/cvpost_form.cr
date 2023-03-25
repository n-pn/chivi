require "json"

struct CV::CvpostForm
  include JSON::Serializable

  getter db_id : Int32 = 0 # dboard id
  getter labels : String = ""

  getter title : String
  getter btext : String

  def after_initialize
    @title = @title.strip
    @btext = @btext.strip
  end
end
