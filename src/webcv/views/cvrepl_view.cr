require "./_base_view"

struct CV::CvreplView
  include BaseView

  def initialize(@data : Cvrepl, @full = false, @memo : UserRepl? = nil)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id
      jb.field "no", @data.ii
      jb.field "dt", @data.cvpost.oid

      if @full
        jb.field "db_bname", @data.cvpost.nvinfo.vname
        jb.field "db_bslug", @data.cvpost.nvinfo.bslug
        jb.field "dt_title", @data.cvpost.title
        jb.field "dt_tslug", @data.cvpost.tslug
      end

      jb.field "u_dname", @data.cvuser.uname
      jb.field "u_privi", @data.cvuser.privi

      if @data.repl_cvrepl_id > 0
        repl = Cvrepl.load!(@data.repl_cvrepl_id)

        jb.field "rp_id", repl.id
        jb.field "rp_no", repl.ii
        jb.field "ru_dname", repl.cvuser.uname
        jb.field "ru_privi", repl.cvuser.privi
      end

      jb.field "ohtml", @data.ohtml
      jb.field "odesc", @data.otext.split("\n", 2).first?

      jb.field "state", @data.state
      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime

      jb.field "edit_count", @data.edit_count
      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "coins", @data.coins

      if memo = @memo
        jb.field "self_liked", memo.liked
        jb.field "self_rp_ii", memo.last_rp_ii
      end
    }
  end
end
