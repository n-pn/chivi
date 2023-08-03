require "../../ysapp/data/ysbook_data"
require "../../zdeps/data/ysbook"

db = ZD::Ysbook.db

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  inputs = YS::Ysbook.query.where("id >= #{lower} and id <= #{upper}").to_a
  puts "- block: #{block}, books: #{inputs.size}"

  break if inputs.empty?

  db.exec "begin"

  inputs.each do |input|
    entry = ZD::Ysbook.new(input.id)
    entry.wn_id = input.nvinfo_id

    entry.btitle = input.btitle
    entry.author = input.author

    entry.cover = input.cover
    entry.intro = input.intro
    entry.genre = input.genre
    entry.xtags = input.btags.join('\t')

    entry.voters = input.voters
    entry.rating = input.rating
    entry.status = input.status
    entry.shield = input.shield
    entry.origin = input.sources[0]? || ""

    entry.word_count = input.word_count
    entry.book_mtime = input.book_mtime

    entry.crit_total = input.crit_total
    entry.list_total = input.list_total

    entry.crit_count = input.crit_count
    entry.list_count = input.list_count

    entry.rtime = input.info_rtime
    entry._flag = 0

    entry.upsert!(db)
  end

  db.exec "commit"
end
