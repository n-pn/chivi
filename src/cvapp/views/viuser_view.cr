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
        jb.field "vcoin", @data.vcoin.round(3)
        jb.field "until", @data.p_exp

        jb.field "unread_notif", Unotif.count_unread(@data.id)
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
