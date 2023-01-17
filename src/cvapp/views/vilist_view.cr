require "./_base_view"

struct CV::VilistView
  include BaseView

  enum Mode
    Full; Crit; List
  end

  def initialize(@data : Vilist, @mode : Mode = :full)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id
      jb.field "user_id", @data.viuser_id

      jb.field "title", @data.title
      jb.field "tslug", @data.tslug

      unless @mode.crit?
        jb.field "covers", @data.covers
        jb.field "genres", @data.genres
      end

      jb.field "book_count", @data.book_count

      if @mode.full?
        jb.field "ctime", @data.created_at.to_unix
        jb.field "dhtml", @data.dhtml

        jb.field "like_count", @data.like_count
        jb.field "star_count", @data.star_count
      end
    }
  end
end
