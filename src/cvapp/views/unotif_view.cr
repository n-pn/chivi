require "./_base_view"

struct CV::UnotifView
  include BaseView

  def initialize(@data : Unotif)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "id", @data.id
      jb.field "content", @data.content
      jb.field "link_to", @data.link_to

      jb.field "created_at", @data.created_at.to_unix
      jb.field "reached_at", @data.reached_at.try(&.to_unix)
    end
  end

  def self.as_list(data : Enumerable(Unotif))
    list = [] of self
    data.each { |x| list << new(x) }
    list
  end
end
