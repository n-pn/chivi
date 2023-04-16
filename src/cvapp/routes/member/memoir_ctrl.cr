require "../_ctrl_base"
require "../../../_util/mail_util"

class CV::MemoirCtrl < CV::BaseCtrl
  base "/_db/memos"

  enum MarkAction
    Like; Unlike; Track; Untrack
  end

  @[AC::Route::PUT("/repls/:repl_id/:action")]
  def mark_repl(repl_id : Int32, action : MarkAction)
    guard_privi 0, "tương tác với phản hồi"

    target = Murepl.find!({id: repl_id})
    memoir = Memoir.load(_vu_id, :murepl, repl_id)

    do_mark_action(memoir, target, action)

    render json: {
      like_count: target.like_count,
      memo_liked: memoir.liked_at,
    }
  end

  @[AC::Route::PUT("/posts/:post_id/:action")]
  def mark_post(post_id : Int32, action : MarkAction)
    guard_privi 0, "tương tác với chủ đề"

    target = Dtopic.find!({id: post_id})
    memoir = Memoir.load(_vu_id, :dtopic, post_id)

    do_mark_action(memoir, target, action)

    render json: {
      like_count: target.like_count,
      memo_liked: memoir.liked_at,
      memo_track: memoir.track_at,
    }
  end

  private def do_mark_action(memoir : Memoir, target : Dtopic | Murepl, action : MarkAction)
    utc_unix = Time.utc.to_unix

    case action
    in .like?
      raise BadRequest.new("Thông tin sai lệch") if memoir.liked_at > 0
      memoir.liked_at = utc_unix
      target.like_count += 1
    in .unlike?
      raise BadRequest.new("Thông tin sai lệch") unless memoir.liked_at > 0
      memoir.liked_at = -utc_unix
      target.like_count -= 1
    in .track?
      raise BadRequest.new("Thông tin sai lệch") if memoir.track_at > 0
      memoir.track_at = utc_unix
    in .untrack?
      raise BadRequest.new("Thông tin sai lệch") unless memoir.track_at > 0
      memoir.track_at = -utc_unix
    end

    if memoir.viewed_at < utc_unix
      memoir.viewed_at = utc_unix
    end

    target.save!
    memoir.save!

    spawn do
      case action
      when .like?   then memoir.create_like_notif!(target, _uname)
      when .unlike? then memoir.remove_like_notif!(target)
      end
    end
  end
end
