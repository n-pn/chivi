require "../../src/_data/dboard/murepl"
require "../../src/_data/dboard/dtopic"
require "../../src/_data/member/memoir"
require "../../src/_data/member/unotif"

CV::Murepl.query.order_by(id: :asc).each do |repl|
  puts [repl.id, repl.viuser_id, repl.touser_id, repl.torepl_id, repl.itext]

  CV::Unotif.create_repl_notif(repl)
  CV::Unotif.create_tagged_notif(repl)
end
