require "./_base_view"

struct CV::MemoirView
  include BaseView

  def initialize(@data : Memoir, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "liked", @data.liked_at
      jb.field "track", @data.track_at

      jb.field "tagged", @data.tagged_at
      jb.field "viewed", @data.viewed_at

      jb.field "extra", @data.extra
    }
  end

  def self.as_list(data : Enumerable(Memoir), full = false)
    list = [] of self
    data.each { |x| list << new(x, full: full) }
    list
  end

  def self.as_hash(data : Enumerable(Memoir), full = false)
    hash = {} of Int32 => self
    data.each { |obj| hash[obj.target_id] = new(obj, full: full) }
    hash
  end
end
