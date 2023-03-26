require "./_base_view"

struct CV::CvreplView
  include BaseView

  @memo : UserRepl?

  def initialize(@data : Cvrepl, @full : Bool = false,
                 @memo = nil)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id

      jb.field "post_id", @data.cvpost_id
      jb.field "repl_id", @data.repl_cvrepl_id

      jb.field "u_dname", @data.viuser.uname
      jb.field "u_privi", @data.viuser.privi

      jb.field "ohtml", @data.ohtml

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime

      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "coins", @data.coins
      jb.field "repls", [] of Cvrepl

      if memo = @memo
        jb.field "self_liked", memo.liked
        jb.field "self_rp_ii", memo.last_rp_ii
      end
    }
  end
end
