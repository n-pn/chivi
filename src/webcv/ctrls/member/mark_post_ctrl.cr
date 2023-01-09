require "../_ctrl_base"
require "../../../_util/mail_util"

class CV::MarkReplCtrl < CV::BaseCtrl
  base "/api/!posts"

  enum MarkAction
    Like; Unlike
  end

  @[AC::Route::PUT("/:post_id/:action", converter: {post_id: ConvertBase32})]
  def mark_post(post_id : Int64, action : MarkAction)
    raise Unauthorized.new("Bạn chưa đăng nhập") unless _viuser.can?(:mark_post)

    cvpost = Cvpost.load!(post_id)
    target = UserPost.find_or_new(_viuser.id, cvpost.id)

    amount = 0

    case action
    when .like?
      raise BadRequest.new("Bạn đã ưa thích bài viết") if target.liked
      amount = 1
    when .unlike?
      raise BadRequest.new("Bạn chưa ưa thích bài viết") unless target.liked
      amount = -1
    end

    cvpost.inc_like_count!(amount)
    target.set_liked!(value > 0)

    render json: {like_count: cvpost.like_count}
  end
end
