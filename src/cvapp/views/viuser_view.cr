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
        jb.field "until", @data.until
      end
    }
  end

  def self.as_hash(inp : Enumerable(Viuser))
    res = {} of Int64 => self
    inp.each { |obj| res[obj.id] = new(obj, full: false) }
    res
  end
end
