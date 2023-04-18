require "../../src/_data/member/unotif"

queue = CV::Unotif.db.query_all "select id, _undo_tag_ from unotifs where _undo_tag_ <> ''", as: {Int32, String}

queue.each do |id, tag|
  puts tag
  byuser, action, target = tag.split(':')

  action = action == "like_repl" ? 1 : 2
  CV::Unotif.db.exec <<-SQL, action, target, byuser, id
    update unotifs set "action" = $1, object_id = $2, byuser_id = $3
    where id = $4
    SQL
end
