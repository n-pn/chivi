require "./_base_view"

struct CV::DtopicView
  include BaseView

  def initialize(@data : Dtopic, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "dboard" do
        jb.object {
          jb.field "id", @data.nvinfo.id
          jb.field "bname", @data.nvinfo.vname
          jb.field "bslug", @data.nvinfo.bslug
        }
      end

      jb.field "id", @data.id
      jb.field "user_id", @data.viuser_id

      jb.field "title", @data.title
      jb.field "tslug", @data.tslug
      jb.field "brief", @data.brief

      jb.field "labels", @data.labels

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime
      jb.field "state", @data.state

      jb.field "post_count", @data.repl_count
      jb.field "like_count", @data.like_count
      jb.field "view_count", @data.view_count

      if @full
        jb.field "bhtml", @data.bhtml
      end
    }
  end

  def self.as_list(data : Enumerable(Dtopic), full = false)
    list = [] of self
    data.each { |x| list << new(x, full: full) }
    list
  end
end
