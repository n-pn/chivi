require "./_base_view"

struct CV::GdrootView
  include BaseView

  enum Mode
    List
    Head
    Full
  end

  def initialize(@data : Gdroot, @mode : Mode = :full)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id
      jb.field "rkey", @data.rkey
      jb.field "user_id", @data.viuser_id

      if @mode.list? || @mode.full?
        jb.field "ctime", @data.created_at.to_unix
        jb.field "utime", @data.updated_at.to_unix

        jb.field "dtype", @data.thread_type
        jb.field "title", @data.title
        jb.field "rlink", @data.rlink

        jb.field "olink", @data.olink
        jb.field "oname", @data.oname

        jb.field "like_count", @data.like_count
        jb.field "repl_count", @data.repl_count
        jb.field "view_count", @data.view_count
      end
    }
  end

  def self.as_list(data : Enumerable(Gdroot))
    list = [] of self
    data.each { |x| list << new(x, mode: :list) }
    list
  end

  def self.as_hash(data : Enumerable(Gdroot))
    hash = {} of Int32 => self
    data.each { |x| hash[x.id] = new(x, mode: :head) }
    hash
  end
end
