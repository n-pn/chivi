require "./_base_view"

struct CV::YsreplView
  include BaseView

  def initialize(@data : Ysrepl)
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "uname", @data.ysuser.vname
      jb.field "uslug", @data.ysuser.id
      jb.field "vhtml", @data.vhtml

      jb.field "mftime", @data.created_at.to_unix
      jb.field "like_count", @data.like_count
    end
  end
end
