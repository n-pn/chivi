require "./_base_view"

struct CV::ViuserView
  include BaseView

  def initialize(@data : Viuser)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "vu_id", @data.id
      jb.field "uname", @data.uname
      jb.field "privi", @data.privi
    }
  end

  def self.as_list(data : Enumerable(Viuser))
    data.to_a.map { |x| new(x) }
  end

  def self.as_hash(data : Enumerable(Viuser))
    data.to_a.to_h { |x| {x.id, new(x)} }
  end
end

struct CV::ViuserFull
  include BaseView

  def initialize(@vuser : Viuser, @uquota : Uquota)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "vu_id", @vuser.id
      jb.field "uname", @vuser.uname
      jb.field "privi", @vuser.privi

      jb.field "until", @vuser.p_exp
      jb.field "vcoin", @vuser.vcoin.round(3)
      jb.field "quota", @uquota.quota_limit - @uquota.quota_using

      jb.field "unread_notif", Unotif.count_unread(@vuser.id)
    }
  end
end
