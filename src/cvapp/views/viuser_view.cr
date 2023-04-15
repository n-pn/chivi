require "./_base_view"

struct CV::ViuserView
  include BaseView

  def initialize(@data : Viuser, @full = true)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "vu_id", @data.id

      jb.field "uname", @data.uname
      jb.field "privi", @data.privi

      if @full
        jb.field "vcoin", @data.vcoin.round(2)
        jb.field "until", @data.current_privi_until

        jb.field "point_today", QtranXlog.today_point_cost(@data.id)
        jb.field "point_limit", @data.point_limit
      end
    }
  end

  def self.as_list(data : Enumerable(Viuser), full = false)
    list = [] of self
    data.each { |x| list << new(x, full) }
    list
  end

  def self.as_hash(data : Enumerable(Viuser))
    hash = {} of Int32 => self
    data.each { |x| hash[x.id] = new(x, full: false) }
    hash
  end
end
