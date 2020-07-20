require "../../src/kernel/book_repo"
require "../../src/kernel/chap_repo"

SITES = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
  "yousuu",
}

UBIDS = Set(String).new

SITES.each do |site|
  infos = LabelMap.load!("_import/sites/#{site}")

  infos.each do |sbid, info|
    ubid, title, author = info.split("¦")
    new_title = BookRepo::Utils.fix_zh_title(title)

    if title != new_title
      puts "- title: #{title} -> #{new_title} [#{sbid} - #{ubid}]"
      title = new_title
    end

    new_author = BookRepo::Utils.fix_zh_author(author, title)

    if author != new_author
      puts "- author: #{author} -> #{new_author} [#{sbid} - #{ubid}]"
      author = new_author
    end

    new_ubid = UuidUtil.gen_ubid(title, author)

    infos.upsert(sbid, "#{new_ubid}¦#{title}¦#{author}") if ubid != new_ubid
    UBIDS.add(new_ubid)
  end

  infos.save!
end

BookInfo.ubids.each do |ubid|
  next if UBIDS.includes?(ubid)
  puts "- DEAD ENTRY: #{ubid}"

  File.delete(BookInfo.path_for(ubid))
  FileUtils.rm_rf(ChapList.path_for(ubid))
end
