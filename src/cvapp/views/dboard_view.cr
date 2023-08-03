require "./_base_view"

struct CV::DboardView
  include BaseView

  def initialize(@data : Wninfo)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id

      jb.field "bname", @data.btitle_vi
      jb.field "bslug", "#{@data.id}-#{@data.bslug}"

      jb.field "post_count", @data.post_count
    }
  end
end
