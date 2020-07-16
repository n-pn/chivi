require "../../src/models/book_info"
require "../../src/models/chap_list"

require "../../src/lookup/label_map"
require "../../src/parser/source_util"

SITES = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
  "yousuu",
}

UBIDS = Set(String).new

SITES.each do |site|
  sbid_ubids = LabelMap.load!("sitemaps/#{site}--ubid")
  sbid_titles = LabelMap.load!("sitemaps/#{site}--title")
  sbid_authors = LabelMap.load!("sitemaps/#{site}--author")

  sbid_ubids.each do |sbid, ubid|
    next unless title = sbid_titles.fetch(sbid)
    new_title = SourceUtil.fix_title(title)

    if title != new_title
      puts "- title changed: #{title} -> #{new_title} [#{sbid} - #{ubid}]"
      sbid_titles.upsert(sbid, new_title)
      title = new_title
    end

    next unless author = sbid_authors.fetch(sbid)
    new_author = SourceUtil.fix_author(author, title)

    if author != new_author
      puts "- author changed: #{author} -> #{new_author} [#{sbid} - #{ubid}]"
      sbid_authors.upsert(sbid, new_author)
      author = new_author
    end

    new_ubid = BookInfo.ubid_for(title, author)
    sbid_ubids.upsert(sbid, ubid) if ubid != new_ubid
    UBIDS.add(new_ubid)
  end

  sbid_ubids.save!
  sbid_titles.save!
  sbid_authors.save!
end

BookInfo.ubids.each do |ubid|
  next if UBIDS.includes?(ubid)
  puts "- DEAD ENTRY: #{ubid}"

  File.delete(BookInfo.path_for(ubid))
  FileUtils.rm_rf(ChapList.path_for(ubid))
end
