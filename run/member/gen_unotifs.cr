require "../../src/_data/notifier"
# CV::Rpnode.query.order_by(id: :asc).each do |repl|
#   puts [repl.id, repl.viuser_id, repl.touser_id, repl.torepl_id, repl.itext]

#   CV::Unotif.create_repl_notif(repl)
#   CV::Unotif.create_tagged_notif(repl)
# end

CV::Memoir.query.order_by(id: :asc).each do |memo|
  next unless memo.liked_at > 0

  target = memo.target
  viuser = CV::Viuser.load!(memo.viuser_id)

  memo.create_like_notif!(target, viuser.uname)
end
