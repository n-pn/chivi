require "json"

struct CV::DtopicForm
  include JSON::Serializable

  getter db_id : Int32 = 0 # dboard id
  getter htags : String = ""

  getter title : String
  getter btext : String

  def after_initialize
    @title = @title.strip
    @btext = @btext.strip
  end
end
