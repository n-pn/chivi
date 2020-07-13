# fix `var/label_maps/seeds/*` info after fix titles and authors

require "../../src/kernel/label_map"
require "../../src/source/source_util"
require "../../src/_utils/gen_ubids"

SEEDS = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
  "yousuu",
}

SEEDS.each do |seed|
  seed_ubids = LabelMap.load("sitemaps/#{seed}--sbid--ubid")
  seed_titles = LabelMap.load("sitemaps/#{seed}--sbid--title")
  seed_authors = LabelMap.load("sitemaps/#{seed}--sbid--author")

  seed_ubids.each do |sbid, ubid|
    next unless title = seed_titles.fetch(sbid)
    new_title = SourceUtil.fix_title(title)

    if title != new_title
      puts "changed! #{title} - #{new_title}"
      seed_titles.upsert(sbid, new_title)
      title = new_title
    end

    next unless author = seed_authors.fetch(sbid)
    new_author = SourceUtil.fix_author(author, title)

    if author != new_author
      puts "changed! #{author} - #{new_author}"
      seed_authors.upsert(sbid, new_author)
      author = new_author
    end

    new_ubid = Utils.gen_ubid(title, author)

    if ubid != new_ubid
      seed_ubids.upsert(sbid, ubid)
    end
  end

  seed_ubids.save!
  seed_titles.save!
  seed_authors.save!
end
