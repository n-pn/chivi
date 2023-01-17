require "./_base_view"

struct CV::VicritView
  include BaseView

  def initialize(@data : Vicrit, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id
      jb.field "user_id", @data.viuser_id
      jb.field "book_id", @data.nvinfo_id
      jb.field "list_id", @data.vilist_id

      jb.field "stars", @data.stars
      jb.field "ohtml", @data.ohtml
      jb.field "btags", @data.btags

      jb.field "ctime", @data.created_at.to_unix
      jb.field "edited", !!@data.changed_at

      jb.field "repl_count", @data.repl_count
      jb.field "like_count", @data.like_count
    }
  end
end
