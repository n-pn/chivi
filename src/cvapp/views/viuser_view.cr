require "./_base_view"

struct CV::ViuserView
  include BaseView

  def initialize(@data : Viuser, @full = true)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "uname", @data.uname
      jb.field "privi", @data.privi

      if @full
        jb.field "vcoin", @data.vcoin
        jb.field "until", @data.until
      end
    }
  end
end
