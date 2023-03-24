require "./_base_view"

struct CV::MemoirView
  include BaseView

  def initialize(@data : UserRepl | UserPost, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "liked", @data.liked
      jb.field "atime", @data.updated_at.to_unix
    }
  end
end
