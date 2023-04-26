require "../../src/_data/notifier/*"
# CV::Rpnode.query.order_by(id: :asc).each do |repl|
#   puts [repl.id, repl.viuser_id, repl.touser_id, repl.torepl_id, repl.itext]

#   CV::Unotif.create_repl_notif(repl)
#   CV::Unotif.create_tagged_notif(repl)
# end

CV::Memoir.query.order_by(id: :asc).each do |memoir|
  next unless memoir.liked_at > 0

  target = memoir.target
  byuser = CV::Viuser.get_uname(memoir.viuser_id)
  puts CV::Notifier.on_like_event(target, memoir, byuser).to_pretty_json
end
