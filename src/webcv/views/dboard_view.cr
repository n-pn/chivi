require "./_base_view"

class CV::DboardView
  include BaseView

  def initialize(@data : Dboard)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id

      jb.field "bname", @data.bname
      jb.field "bslug", @data.bslug

      jb.field "post_count", @data.posts
      jb.field "view_count", @data.views
    }
  end
end
