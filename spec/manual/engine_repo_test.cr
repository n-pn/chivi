require "../src/repo"

repo = Chivi::Repo.new

puts repo.hanviet.size
puts repo.combine.size
puts repo.unique("not-found").size
