require "./_base_view"

struct CV::ViuserView
  include BaseView

  def initialize(@data : Viuser, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "uname", @data.uname
      jb.field "privi", @data.privi

      if @full
        jb.field "vcoin_avail", @data.vcoin_avail
        jb.field "vcoin_total", @data.vcoin_total

        jb.field "privi_1_until", @data.privi_1_until
        jb.field "privi_2_until", @data.privi_2_until
        jb.field "privi_3_until", @data.privi_3_until
      end
    }
  end
end
