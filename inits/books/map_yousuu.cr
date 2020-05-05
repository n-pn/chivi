require "json"
require "colorize"
require "file_utils"

require "../../src/models/ys_info"
require "../../src/models/vp_info"

alias Data = NamedTuple(bookInfo: Serial, bookSource: Array(Source))

sitemap = [] of String
inputs = {} of String => Serial

glob = File.join("data", ".inits", "txt-inp", "yousuu", "infos", "*.json")
Dir.glob(glob).each do |file|
  text = File.read(file)

  next unless text.includes?("{\"success\":true")

  input = NamedTuple(data: Data).from_json(text)
  serial = input[:data][:bookInfo]

  serial.fix_title!
  serial.fix_author!

  sitemap << [serial._id.to_s, serial.uuid, serial.title, serial.author].join("--")

  next if serial.score == 0 || serial.title.empty? || serial.author.empty?

  if old_serial = inputs[serial.uuid]?
    next if old_serial.updateAt >= serial.updateAt
  end

  serial.fix_cover!
  serial.fix_genre!
  serial.fix_tags!

  serial.sources = input[:data][:bookSource]

  inputs[serial.uuid] = serial
rescue err
  File.delete(file)
  puts "#{file} err: #{err}".colorize(:red)
end

File.write(File.join("data", "sitemaps", "yousuu.txt"), sitemap.join("\n"))

FileUtils.mkdir_p(VpInfo::DIR)

infos = VpInfo.load_all
fresh = 0

inputs.each do |uuid, serial|
  unless info = infos[uuid]?
    fresh += 1
    info = VpInfo.new(serial.title, serial.author, uuid: uuid)
  end

  info.set_intro_zh(serial.intro, force: true)
  info.set_genre_zh(serial.genre, force: true)
  info.set_tags_zh(serial.tags)
  info.add_cover(serial.cover)

  info.votes = serial.scorerCount
  info.score = (serial.score * 10).round / 10
  info.reset_tally

  info.shield = serial.shielded ? 2 : 0
  info.set_status(serial.status)
  info.set_update(serial.updateAt.to_unix_ms)

  info.yousuu = serial._id.to_s
  if source = serial.sources.first?
    info.origin = source.link
  end

  info.word_count = serial.countWord.round.to_i
  info.crit_count = serial.commentCount

  VpInfo.save_json(info)
end

puts "- existed: #{infos.size.colorize(:blue)}, fresh: #{fresh.colorize(:blue)}"
