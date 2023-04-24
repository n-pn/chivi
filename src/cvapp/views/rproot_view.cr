require "./_base_view"

struct CV::RprootView
  include BaseView

  enum Mode
    List
    Head
    Full
  end

  def initialize(@data : Rproot, @mode : Mode = :full)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id
      jb.field "root", @data.root_id

      if @mode.head?
        jb.field "link", @data._link
      end

      if @mode.list? || @mode.full?
        jb.field "type", @data._type
        jb.field "name", @data._name
        jb.field "link", @data._link

        jb.field "repl_count", @data.repl_count
        jb.field "created_at", @data.created_at.to_unix
      end
    }
  end

  def self.as_list(data : Enumerable(Rproot))
    list = [] of self
    data.each { |x| list << new(x, mode: :list) }
    list
  end

  def self.as_hash(data : Enumerable(Rproot))
    hash = {} of Int32 => self
    data.each { |x| hash[x.id] = new(x, mode: :head) }
    hash
  end
end
