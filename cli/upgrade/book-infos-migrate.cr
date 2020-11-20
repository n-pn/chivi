require "../../src/kernel/book_info"
require "../../src/filedb/*"
require "../../src/_utils/text_util"

infos = BookInfo.preload_all!
puts "- Total: #{infos.size} entries".colorize.cyan

OUT = "_db/prime/serial"

bhash = ValueMap.new("#{OUT}/infos/bhash.tsv")
bslug = ValueMap.new("#{OUT}/infos/bslug.tsv")

title_zh = ValueMap.new("#{OUT}/infos/title_zh.tsv")
title_zh_qs = TokenMap.new("#{OUT}/infos/title_zh_qs.tsv")

title_vi = ValueMap.new("#{OUT}/infos/title_vi.tsv")
title_vi_qs = TokenMap.new("#{OUT}/infos/title_vi_qs.tsv")

title_hv = ValueMap.new("#{OUT}/infos/title_hv.tsv")
title_hv_qs = TokenMap.new("#{OUT}/infos/title_hv_qs.tsv")

author_zh = ValueMap.new("#{OUT}/infos/author_zh.tsv")
author_zh_qs = TokenMap.new("#{OUT}/infos/author_zh_qs.tsv")

author_vi = ValueMap.new("#{OUT}/infos/author_vi.tsv")
author_vi_qs = TokenMap.new("#{OUT}/infos/author_vi_qs.tsv")

genres_vi = ValueMap.new("#{OUT}/infos/genres_vi.tsv")
genres_vi_qs = TokenMap.new("#{OUT}/infos/genres_vi_qs.tsv")

intro_zh = ValueMap.new("#{OUT}/infos/intro_zh.tsv")
intro_vi = ValueMap.new("#{OUT}/infos/intro_vi.tsv")

voters = OrderMap.new("#{OUT}/infos/voters.tsv")
rating = OrderMap.new("#{OUT}/infos/rating.tsv")
weight = OrderMap.new("#{OUT}/infos/weight.tsv")

shield = ValueMap.new("#{OUT}/infos/shield.tsv")
status = ValueMap.new("#{OUT}/infos/status.tsv")
update = OrderMap.new("#{OUT}/infos/update.tsv")
access = OrderMap.new("#{OUT}/infos/access.tsv")

count_words = ValueMap.new("#{OUT}/infos/count_words.tsv")
count_crits = ValueMap.new("#{OUT}/infos/count_crits.tsv")

cover_name = ValueMap.new("#{OUT}/infos/cover_name.tsv")
yousuu_bid = ValueMap.new("#{OUT}/infos/yousuu_bid.tsv")
origin_url = ValueMap.new("#{OUT}/infos/origin_url.tsv")

seeds = TokenMap.new("#{OUT}/infos/seeds.tsv")

struct SeedInfo
  getter s_bid, utime, ch_text, ch_link, ch_slug, cover

  def initialize(seed : String)
    dir = "#{OUT}/seeds/#{seed}"
    FileUtils.mkdir_p(dir)

    @s_bid = ValueMap.new("#{dir}/s_bid.tsv")
    @utime = ValueMap.new("#{dir}/utime.tsv")
    @cover = ValueMap.new("#{dir}/cover.tsv")
    @ch_text = ValueMap.new("#{dir}/ch_text.tsv")
    @ch_link = ValueMap.new("#{dir}/ch_link.tsv")
  end

  def save!
    @s_bid.save!
    @utime.save!
    @cover.save!
    @ch_text.save!
    @ch_link.save!
  end
end

SEEDS = Hash(String, SeedInfo).new { |h, k| h[k] = SeedInfo.new(k) }

infos.values.each_with_index do |info, idx|
  puts "- <#{idx + 1}/#{infos.size}> #{info.slug}" if idx % 100 == 99

  bhash.upsert!(info.slug, info.ubid, mtime: 0)
  bslug.upsert!(info.ubid, info.slug, mtime: 0)

  title_zh.upsert!(info.ubid, info.zh_title, mtime: 0)
  title_zh_qs.upsert!(info.ubid, TextUtil.tokenize(info.zh_title), mtime: 0)

  title_vi.upsert!(info.ubid, info.vi_title, mtime: 0)
  title_vi_qs.upsert!(info.ubid, TextUtil.tokenize(info.vi_title), mtime: 0)

  title_hv.upsert!(info.ubid, info.hv_title, mtime: 0)
  title_hv_qs.upsert!(info.ubid, TextUtil.tokenize(info.hv_title), mtime: 0)

  author_zh.upsert!(info.ubid, info.zh_author, mtime: 0)
  author_zh_qs.upsert!(info.ubid, TextUtil.tokenize(info.zh_author), mtime: 0)

  author_vi.upsert!(info.ubid, info.vi_author, mtime: 0)
  author_vi_qs.upsert!(info.ubid, TextUtil.tokenize(info.vi_author), mtime: 0)

  genres_vi.upsert!(info.ubid, info.vi_genres.join("  "), mtime: 0)
  genres_vi_qs.upsert!(info.ubid, info.vi_genres.map { |x| TextUtil.slugify(x) }, mtime: 0)

  intro_zh.upsert!(info.ubid, info.zh_intro.gsub("\n", "  "), mtime: 0)
  intro_vi.upsert!(info.ubid, info.vi_intro.gsub("\n", "  "), mtime: 0)

  voters.upsert!(info.ubid, info.voters, mtime: 0)
  rating.upsert!(info.ubid, info.rating.*(10).to_i, mtime: 0)

  weight_value = info.voters > 0 ? info.rating * Math.log(info.voters) * 100 : 0.0
  weight.upsert!(info.ubid, weight_value.to_i, mtime: 0)

  shield.upsert!(info.ubid, info.shield.to_s, mtime: 0)
  status.upsert!(info.ubid, info.status.to_s, mtime: 0)

  mftime = (info.mftime // 1000).to_i # by 1 seconds
  update.upsert!(info.ubid, mftime, mtime: 0)
  access.upsert!(info.ubid, mftime // 600, mtime: 0) # by 5 minutes

  count_words.upsert!(info.ubid, info.word_count.to_s, mtime: 0)
  count_crits.upsert!(info.ubid, info.crit_count.to_s, mtime: 0)

  cover_name.upsert!(info.ubid, info.main_cover, mtime: 0)

  origin_url.upsert!(info.ubid, info.origin_url, mtime: 0) unless info.origin_url.empty?

  seeds.upsert!(info.ubid, info.seed_names, mtime: 0)

  SEEDS["yousuu"].tap do |seed|
    seed.s_bid.upsert!(info.ubid, info.yousuu_bid, mtime: 0)
  end

  info.seed_sbids.each do |sname, s_bid|
    SEEDS[sname].tap do |seed|
      seed.s_bid.upsert!(info.ubid, s_bid, mtime: 0)

      utime = info.seed_mftimes[sname]?.try(&.//(1000).to_i) || 0
      seed.utime.upsert!(info.ubid, utime.to_s, mtime: 0)

      seed.cover.upsert!(info.ubid, info.cover_urls[sname]? || "", mtime: 0)

      if chap = info.seed_latests[sname]?
        seed.ch_text.upsert!(info.ubid, chap.vi_title, mtime: 0)
        seed.ch_link.upsert!(info.ubid, "#{chap.url_slug}-#{sname}-#{chap.scid}", mtime: 0)
      end
    end
  end
end

bhash.save!
bslug.save!

title_zh.save!
title_zh_qs.save!
title_vi.save!
title_vi_qs.save!
title_hv.save!
title_hv_qs.save!

author_zh.save!
author_zh_qs.save!
author_vi.save!
author_vi_qs.save!

genres_vi.save!
genres_vi_qs.save!

intro_zh.save!
intro_vi.save!

voters.save!
rating.save!
weight.save!

shield.save!
status.save!

update.save!
access.save!

count_words.save!
count_crits.save!

cover_name.save!
yousuu_bid.save!
origin_url.save!

seeds.save!

SEEDS.each_value(&.save!)
