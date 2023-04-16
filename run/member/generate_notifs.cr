require "../../src/_data/dboard/murepl"
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

    from_user = CV::Viuser.load!(memo.viuser_id)

    thread_type, thread_link, thread_name = murepl.thread_data

    unotif = CV::Unotif.new_repl_like(
      viuser_id: murepl.viuser_id,
      from_user: from_user.uname,
      murepl_id: murepl.id,
      repl_peak: murepl.repl_peak,
      thread_type: thread_type,
      thread_link: thread_link,
      thread_name: thread_name
    )

    unotif.created_at = Time.unix(memo.liked_at)

    puts unotif.to_pretty_json
  end
end
