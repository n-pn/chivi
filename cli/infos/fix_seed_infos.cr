# fix `var/label_maps/seeds/*` info after fix titles and authors

require "../../src/kernel/label_map"
require "../../src/source/source_util"
require "../../src/_utils/gen_uuids"

SEEDS = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu",
}

SEEDS.each do |seed|
  seed_uuids = LabelMap.load("seeds/#{seed}_uuids")
  seed_titles = LabelMap.load("seeds/#{seed}_titles")
  seed_authors = LabelMap.load("seeds/#{seed}_authors")

  seed_uuids.each do |sbid, uuid|
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

    new_uuid = Utils.gen_uuid(title, author)

    if uuid != new_uuid
      seed_uuids.upsert(sbid, uuid)
    end
  end

  seed_uuids.save!
  seed_titles.save!
  seed_authors.save!
end
