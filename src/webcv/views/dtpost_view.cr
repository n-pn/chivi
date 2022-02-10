require "./_base_view"

struct CV::DtpostView
  include BaseView

  def initialize(@data : Dtpost, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id
      jb.field "no", @data.ii
      jb.field "dt", @data.dtopic.oid

      if @full
        jb.field "db_bname", @data.dtopic.nvinfo.vname
        jb.field "db_bslug", @data.dtopic.nvinfo.bslug
        jb.field "dt_title", @data.dtopic.title
        jb.field "dt_tslug", @data.dtopic.tslug
      end

      jb.field "u_dname", @data.cvuser.uname
      jb.field "_cvuser.privi", @data.cvuser.privi

      if @data.repl_dtpost_id > 0
        repl = Dtpost.load!(@data.repl_dtpost_id)

        jb.field "rp_id", repl.id
        jb.field "rp_no", repl.ii
        jb.field "ru_dname", repl.cvuser.uname
        jb.field "r_cvuser.privi", repl.cvuser.privi
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
    }
  end
end
