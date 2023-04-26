require "../_ctrl_base"
require "../../../_util/mail_util"

class CV::MemoirCtrl < CV::BaseCtrl
  base "/_db/memos"

  enum MemoKind
    Like; Unlike; Track; Untrack
  end

  @[AC::Route::PUT("/:type/:o_id/:kind")]
  def memorize(type : Memoir::Type, o_id : Int32, kind : MemoKind)
    guard_privi 0, "tương tác với đối tượng"

    target = Memoir.target(type, o_id)
    memoir = Memoir.load(_vu_id, target)

    utc_unix = Time.utc.to_unix

    case kind
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

    spawn send_notif(target, memoir, kind)

    render json: {
      like_count: target.like_count,
      memo_liked: memoir.liked_at,
      memo_track: memoir.track_at,
    }
  end

  private def send_notif(target, memoir : Memoir, kind : MemoKind)
    return if target.viuser_id == memoir.viuser_id

    case kind
    when .like?   then Notifier.on_like_event(target, memoir, _uname)
    when .unlike? then Notifier.on_unlike_event(target, memoir)
    end
  end
end
