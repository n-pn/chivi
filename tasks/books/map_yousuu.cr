require "json"
require "colorize"
require "file_utils"

require "../../src/bookdb/book_info"
require "../../src/bookdb/models/ys_info"

sitemap = [] of String
inputs = {} of String => YsInfo

INP_DIR = File.join("data", ".inits", "txt-inp", "yousuu", "serials")
Dir.glob(File.join(INP_DIR, "*.json")).each do |file|
  text = File.read(file)
  next unless text.includes?("\"success\"")

  json = NamedTuple(data: JsonData).from_json(text)
  info = json[:data][:bookInfo]

  info.fix_title!
  info.fix_author!

  uuid = Utils.book_uid(info.title, info.author)
  sitemap << {info._id, uuid, info.title, info.author}.join("--")

  # next if info.recom_ignore
  next if info.title.empty? || info.author.empty?
  if info.scorerCount >= 10
    next if info.score < 2.5
  else
    next unless info.commentCount >= 5 || info.addListTotal >= 5
  end

  if old_info = inputs[uuid]?
    next if old_info.updateAt >= info.updateAt
  end

  info.fix_cover!
  info.fix_tags!

  info.sources = json[:data][:bookSource]

  inputs[uuid] = info
rescue err
  # File.deete(file)
  puts "#{file} err: #{err}".colorize(:red)
end

MAP_DIR = File.join("data", "sitemaps")
FileUtils.mkdir_p(MAP_DIR)
File.write(File.join(MAP_DIR, "yousuu.txt"), sitemap.join("\n"))

FileUtils.mkdir_p(VpInfo::DIR)

infos = VpInfo.load_all
fresh = 0

CURRENT = Time.local.to_unix_ms
EPOCH   = Time.local(2010, 1, 1).to_unix_ms

inputs.each do |uuid, input|
  unless info = infos[uuid]?
    fresh += 1
    info = VpInfo.new(input.title, input.author, uuid)
  end

  info.zh_intro = input.intro
  info.zh_genre = input.genre

  info.add_tags(input.tags)
  info.add_cover(input.cover)

  info.votes = input.scorerCount
  info.score = (input.score * 10).round / 10
  info.reset_tally

  info.shield = input.shielded ? 2 : 0
  info.set_status(input.status)

  info.yousuu = input._id.to_s
  if source = input.sources.first?
    info.origin = source.link
  end

  mftime = input.updateAt.to_unix_ms
  if mftime >= CURRENT
    puts "- WRONG TIME: #{info.yousuu}"
    mftime = EPOCH
  end
  info.set_mftime(mftime)

  info.word_count = input.countWord.round.to_i
  info.crit_count = input.commentCount

  VpInfo.save!(info)
end

puts "- existed: #{infos.size.colorize(:blue)}, fresh: #{fresh.colorize(:blue)}"
