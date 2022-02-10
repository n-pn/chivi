require "./_base_view"

struct CV::CvuserView
  include BaseView

  def initialize(@data : Cvuser, @full = false)
  end

  def to_json(jb : JSON::Builder)
    {
      uname:  @data.uname,
      privi:  @data.privi,
      vcoin:  @data.vcoin_avail,
      wtheme: @data.wtheme,

      privi_1_until: @data.privi_1_until,
      privi_2_until: @data.privi_2_until,
      privi_3_until: @data.privi_3_until,
    }.to_json(jb)
  end
end
