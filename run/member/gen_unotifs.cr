require "../../src/_data/dboard/murepl"
require "../../src/_data/dboard/dtopic"
require "../../src/_data/member/memoir"
require "../../src/_data/member/unotif"

# CV::Murepl.query.each do |repl|
#   next if repl.tagged_ids.empty?
#   puts repl.tagged_ids

#   repl.tagged_ids.each do |tagged_id|
#     memoir = CV::Memoir.load(tagged_id, :murepl, repl.id)
#     memoir.tagged_at = repl.utime
#     memoir.save!
#   end
# end

CV::Memoir.query.each do |memo|
  create_like_notif(memo) if memo.liked_at > 0
end

def create_like_notif(memo : CV::Memoir)
  case CV::Memoir::Type.new(memo.target_type)
  when .murepl?
    murepl = CV::Murepl.find!({id: memo.target_id})
    _undo_tag_ = CV::Unotif.gen_undo_tag(murepl.viuser_id, :like_repl, murepl.id)

    # return if CV::Unotif.find_by_utag(_undo_tag_)
    CV::Unotif.remove_notif(_undo_tag_)
    return if murepl.viuser_id == memo.target_id

    from_user = CV::Viuser.load!(memo.viuser_id)
    content, details, link_to = murepl.gen_like_notif(from_user.uname)
    unotif = CV::Unotif.new(murepl.viuser_id, content, details.to_json, link_to, _undo_tag_)

    unotif.created_at = Time.unix(memo.liked_at)
    puts unotif.to_pretty_json

    unotif.create!
  when .dtopic?
    dtopic = CV::Dtopic.find!({id: memo.target_id})
    _undo_tag_ = CV::Unotif.gen_undo_tag(dtopic.viuser_id, :like_dtop, dtopic.id)

    CV::Unotif.remove_notif(_undo_tag_)
    return if dtopic.viuser_id == memo.target_id

    from_user = CV::Viuser.load!(memo.viuser_id)
    content, details, link_to = dtopic.gen_like_notif(from_user.uname)
    unotif = CV::Unotif.new(dtopic.viuser_id, content, details.to_json, link_to, _undo_tag_)

    unotif.created_at = Time.unix(memo.liked_at)
    puts unotif.to_pretty_json
    unotif.create!
  end
end
