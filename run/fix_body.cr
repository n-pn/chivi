require "../src/_data/dboard/murepl"

repls = CV::Rpnode.query

repls.each do |repl|
  puts [repl.id, repl.created_at]
  repl.set_itext(repl.itext.strip)
  repl.save!
end
