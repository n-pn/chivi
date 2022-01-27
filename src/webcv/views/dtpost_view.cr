require "./_base_view"

class CV::DtpostView
  include BaseView

  def initialize(@data : Dtpost, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id
      jb.field "no", @data.dt_id
      jb.field "dt", @data.dtopic_id

      jb.field "u_dname", @data.cvuser.uname
      jb.field "u_privi", @data.cvuser.privi

      if @data.repl_dtpost_id > 0
        repl = Dtpost.load!(@data.repl_dtpost_id)
        jb.field "rp_id", repl.id
        jb.field "rp_no", repl.dt_id
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

      if @full
        jb.field "input", @data.input
        jb.field "itype", @data.itype
      end
    }
  end
end
