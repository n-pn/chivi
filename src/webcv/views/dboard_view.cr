require "./_base_view"

class CV::DboardView
  include BaseView

  def initialize(@data : Nvinfo)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id

      jb.field "bname", @data.vname
      jb.field "bslug", @data.bslug

      jb.field "post_count", @data.dtopic_count
    }
  end
end
