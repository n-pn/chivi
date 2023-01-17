require "../_ctrl_base"
require "../../../_util/mail_util"

class CV::MarkReplCtrl < CV::BaseCtrl
  base "/api/!repls"

  enum MarkAction
    Like; Unlike
  end

  @[AC::Route::PUT("/:repl_id/:action", converters: {repl_id: ConvertBase32})]
  def mark_repl(action : MarkAction)
    raise Unauthorized.new("Bạn chưa đăng nhập") unless _viuser.can?(:mark_post)

    cvrepl = Cvrepl.load!(params["repl_id"].to_i64)
    target = UserRepl.find_or_new(_viuser.id, cvrepl.id)

    amount = 0

    case action
    in .like?
      raise BadRequest.new("Bạn đã ưa thích bình luận") if target.liked
      amount = 1
    in .unlike?
      raise BadRequest.new("Bạn chưa ưa thích bình luận") unless target.liked
      amount = -1
    end

    cvrepl.inc_like_count!(amount)
    target.set_liked!(amount > 0)
    render json: {like_count: cvrepl.like_count}
  end
end
