require "./_base_view"

struct CV::CvpostView
  include BaseView

  def initialize(@data : Cvpost, @full = false, @memo : UserPost? = nil)
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

      jb.field "id", @data.oid

      jb.field "title", @data.title
      jb.field "tslug", @data.tslug
      jb.field "brief", @data.brief

      jb.field "labels", @data.labels

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime
      jb.field "state", @data.state

      jb.field "op_uname", @data.viuser.uname
      jb.field "op_privi", @data.viuser.privi

      jb.field "post_count", @data.repl_count
      jb.field "like_count", @data.like_count
      jb.field "view_count", @data.view_count

      if @full
        jb.field "bhtml", @data.bhtml
      end

      if memo = @memo
        jb.field "self_liked", memo.liked
        jb.field "self_rp_ii", memo.last_rp_ii
      end
    }
  end
end
