require "json"
require "colorize"
require "file_utils"

require "../../src/kernel/book_info"
require "../../src/kernel/book_misc"
require "../../src/kernel/import/yousuu_info"

inputs = {} of String => YousuuInfo

YousuuInfo.files.each do |file|
  next unless info = YousuuInfo.load!(file)
  next if info.worthless?

  if old_info = inputs[info.label]?
    next if old_info.updateAt >= info.updateAt
  end
  inputs[info.label] = info
rescue err
  # File.delete(file)
  puts "- <read_json> #{file} err: #{err}".colorize(:red)
end

puts "- TOTAL: #{inputs.size.colorize(:yellow)}."

BookInfo.setup!
BookMisc.setup!

fresh = 0

inputs.each_value do |input|
  info = BookInfo.init!(input.title, input.author)

  info.add_genre(input.genre)
  info.add_tags(input.tags)

  info.voters = input.scorerCount
  info.rating = (input.score * 10).round / 10
  info.fix_weight!

  BookInfo.save!(info)

  misc = BookMisc.init!(info.uuid)
  fresh += 1 if misc.mftime == 0

  misc.set_intro(input.intro)

  misc.add_cover(input.cover)

  misc.shield = input.shielded ? 2 : 0
  misc.set_status(input.status)

  mftime = input.updateAt.to_unix_ms
  misc.set_mftime(mftime)

  misc.yousuu_link = "https://www.yousuu.com/book/#{input._id}"
  misc.origin_link = input.first_source || ""

  misc.word_count = input.countWord.round.to_i
  misc.crit_count = input.commentCount

  BookMisc.save!(misc)
end

puts "- FRESH: #{fresh.colorize(:yellow)}."
