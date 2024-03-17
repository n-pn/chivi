ENV["CV_ENV"] = "production"

require "../src/_data/_data"

require "../src/mt_sp/data/sq_name"
require "../src/_data/wnovel/btitle"
require "../src/_data/wnovel/author"

# capitalize all words
def titleize(input : String) : String
  return input if input.empty?
  input.split(' ').map { |x| capitalize(x) }.join(' ')
end

# smart capitalize:
# - don't downcase extra characters
# - treat unicode alphanumeric chars as upcase-able
def capitalize(input : String) : String
  String.build(input.size) do |io|
    uncap = true

    input.each_char do |char|
      io << (uncap && char.alphanumeric? ? char.upcase : char)
      uncap = false
    end
  end
end

btitles = CV::Btitle.get_all(db: PGDB)
authors = CV::Author.get_all(db: PGDB)

outputs = btitles.to_h do |btitle|
  output = SP::WnName.new(btitle.bt_zh)

  output.bt_vi = btitle.bt_vi unless btitle.bt_vi.empty?
  # output.bt_vu = btitle.vi_uc unless btitle.vi_uc.empty?
  output.bt_qt = btitle.vi_qt unless btitle.vi_qt.empty?

  output.bt_en = btitle.bt_en unless btitle.bt_en.empty?
  output.bt_eu = btitle.en_uc unless btitle.en_uc.empty?

  output.vi_hv = titleize(btitle.bt_hv) unless btitle.bt_hv.empty?
  output.vi_ms = titleize(btitle.vi_ms) unless btitle.vi_ms.empty?
  output.vi_gg = titleize(btitle.vi_gg) unless btitle.vi_gg.empty?
  output.vi_bd = titleize(btitle.vi_bd) unless btitle.vi_bd.empty?

  output.en_dl = titleize(btitle.en_dl) unless btitle.en_dl.empty?
  output.en_ms = titleize(btitle.en_ms) unless btitle.en_ms.empty?
  output.en_gg = titleize(btitle.en_gg) unless btitle.en_gg.empty?
  output.en_bd = titleize(btitle.en_bd) unless btitle.en_bd.empty?

  {btitle.bt_zh, output}
end

authors.each do |author|
  output = outputs[author.au_zh] ||= SP::WnName.new(author.au_zh)

  output.au_vi = author.au_vi unless author.au_vi.empty?
  # output.au_vu = author.vi_uc unless author.vi_uc.empty?

  output.au_en = author.au_en unless author.au_en.empty?
  output.au_eu = author.en_uc unless author.en_uc.empty?

  output.vi_hv ||= author.au_hv unless author.au_hv.empty?
  output.vi_ms ||= titleize(author.vi_ms) unless author.vi_ms.empty?
  output.vi_gg ||= titleize(author.vi_gg) unless author.vi_gg.empty?
  output.vi_bd ||= titleize(author.vi_bd) unless author.vi_bd.empty?

  output.en_dl ||= titleize(author.en_dl) unless author.en_dl.empty?
  output.en_ms ||= titleize(author.en_ms) unless author.en_ms.empty?
  output.en_gg ||= titleize(author.en_gg) unless author.en_gg.empty?
  output.en_bd ||= titleize(author.en_bd) unless author.en_bd.empty?
end

puts [btitles.size, authors.size, outputs.size]

SP::WnName.db.open_tx do |db|
  outputs.each_value(&.upsert!(db: db))
end
