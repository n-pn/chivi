require "../../src/models/book_info"
require "../../src/models/chap_list"
require "../../src/lookup/label_map"
require "../../src/source/source_util"

SEEDS = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
  "yousuu",
}

UBIDS = Set(String).new

SEEDS.each do |seed|
  seed_ubids = LabelMap.load!("sitemaps/#{seed}--sbid--ubid")
  seed_titles = LabelMap.load!("sitemaps/#{seed}--sbid--title")
  seed_authors = LabelMap.load!("sitemaps/#{seed}--sbid--author")

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

    new_ubid = BookInfo.ubid_for(title, author)
    UBIDS.add(new_ubid)

    if ubid != new_ubid
      seed_ubids.upsert(sbid, ubid)
    end
  end

  seed_ubids.save!
  seed_titles.save!
  seed_authors.save!
end

ubids = BookInfo.ubids

ubids.each do |ubid|
  next if UBIDS.includes?(ubid)
  puts "- DEAD ENTRY: #{ubid}"
  File.delete(BookInfo.path_for(ubid))
  FileUtils.rm_rf(ChapList.path_for(ubid))
end
